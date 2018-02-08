SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.rpt_CurrentInventoryListing_BY_eliu2') IS NULL
    EXEC('
          CREATE PROCEDURE dbo.rpt_CurrentInventoryListing_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO

ALTER PROCEDURE [dbo].[rpt_CurrentInventoryListing_BY_eliu2] (
  @AgentID INT,
  @OutletID INT
)
----------------------------------------------------------------------------------------
-- Description : Percentage of Revenue
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 01/09/2018  HFDNET-16782     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  EXECUTE  dbo.rpt_CurrentInventoryListing 310001,NULL
--  EXECUTE  [dbo].[rpt_CurrentInventoryListing] 302001, 5485
----------------------------------------------------------------------------------------
AS
BEGIN
    DECLARE @LBSFeeAmount MONEY
    DECLARE @LBSFeePercentage DECIMAL(18, 9)
    DECLARE @LBSCapFee MONEY
    DECLARE @LBSRoundToNearest MONEY
    DECLARE @CurrentDate DATETIME
    
    SET @CurrentDate = [dbo].[udf_GetCurrentDateTime]()
    
    IF OBJECT_ID('TEMPDB..#TempTableItemSaleFee') IS NOT NULL
  BEGIN
        DROP TABLE #TempTableItemSaleFee
  END;

    CREATE TABLE #TempTableItemSaleFee
    (ItemID INT,
     FeeTotal MONEY,
     ItemSurCharge MONEY
    );
    
    SELECT
     @LBSFeeAmount = FeeAmount,
     @LBSFeePercentage = FeePercentage,
     @LBSCapFee = FeeCapAmount,
     @LBSRoundToNearest = RoundToNearest
    FROM dbo.udf_GetGlobalDistribution(2, @CurrentDate)
    
    INSERT INTO #TempTableItemSaleFee(ItemID,FeeTotal,ItemSurCharge)
    SELECT ItemID,
           [FeeTotal] = ISNULL([ItemFee],0) + ISNULL([ApplicationFee],0),
           [ItemSurCharge]  = (CASE WHEN ( @LBSCapFee > 0 AND dbo.udf_RoundToTheNearest([ItemLBSFee],     CONVERT( DECIMAL(4,3), @LBSRoundToNearest )) > @LBSCapFee ) THEN 
                                        @LBSCapFee
                                    ELSE
                                        dbo.udf_RoundToTheNearest([ItemLBSFee], CONVERT( DECIMAL(4,3),     @LBSRoundToNearest ))
                              END )
    FROM (
          SELECT
                 I.[ItemID]
                ,[ItemFee] = (SELECT SUM(ISNULL(FeeAmount, 0)) FROM dbo.ItemFee WHERE ItemFeeID =     FG.BaseFeeID)             
                ,[ApplicationFee] = (SELECT SUM(ISNULL(FeeAmount, 0)) FROM dbo.ItemFee WHERE ItemFeeID =     FG.ApplicationFeeID)
                ,[ItemLBSFee] = CASE WHEN IsSurchargeApplicable = 1 AND @LBSFeeAmount > 0 THEN 
                                          @LBSFeeAmount
                                     wHEN IsSurchargeApplicable = 1 AND @LBSFeePercentage > 0 THEN 
                                          ((SELECT SUM(ISNULL(FeeAmount, 0)) FROM dbo.ItemFee WHERE     ItemFeeID IN (FG.ApplicationFeeID, FG.BaseFeeID)) *     @LBSFeePercentage)
                                     ELSE 0
                                END
          FROM dbo.Item I
          INNER JOIN dbo.FeeGroup FG ON I.ItemID = FG.ItemID
    ) TMP

    SELECT O.AgentID,
            'Serialized Inventory' AS InventoryType,
            O.OutletID,
            O.OutletName,
            O.OutletNumber,
            I.InventoryID,
            I.ItemYear,
            I.InventoryItemName,
            I.InventoryNumber,
            I.ExpirationDate,
            COUNT(distinct CI.ControlledInventoryID) QtyOnHand,
            CASE WHEN CI.ConsignedToDFGUserID IS NULL THEN [dbo].[udf_GetOutletSerials](O.OutletID, I.InventoryID, 98)
                 ELSE [dbo].[udf_GetOutletSerialsByClerk](O.OutletID, I.InventoryID, 98, CI.ConsignedToDFGUserID)
            END Serials,
            ISNULL(MAX(CF.FeeTotal + CF.ItemSurCharge), 0) AS Price,  -----------------------------********
            I.IsControlledInventory,
            ISNULL(( P.LastName + ', ' + P.FirstName + ' (' + AU.UserName + ')' ), 'In Stock') Clerk
        FROM dbo.Inventory I
  INNER JOIN dbo.ControlledInventory CI ON CI.InventoryID = I.InventoryID AND I.IsControlledInventory = 1 AND CI.StatusCodeID = 98 --Consigned
  INNER JOIN dbo.Outlet O ON CI.ConsignedToOutletID = O.OutletID
   LEFT JOIN dbo.ApplicationUser AU ON CI.ConsignedToDFGUserID = AU.ApplicationUserID
   LEFT JOIN dbo.Person P ON AU.PersonID = P.PersonID
   LEFT JOIN dbo.Item It ON I.InventoryID = It.InventoryID
   LEFT JOIN dbo.#TempTableItemSaleFee AS CF ON It.ItemID = CF.ItemID ---------------------------------*******
       WHERE O.AgentID = @AgentID AND ( @OutletID IS NULL OR O.OutletID = @OutletID )
    GROUP BY O.AgentID,O.OutletID,O.OutletName,O.OutletNumber
            ,I.InventoryID,I.ItemYear,I.InventoryItemName,I.InventoryNumber,I.ExpirationDate,I.IsControlledInventory
            ,CI.ConsignedToDFGUserID,AU.UserName,P.LastName,P.FirstName            
    UNION
    SELECT O.AgentID,
                'Non Serialized Inventory' AS InventoryType,
                O.OutletID,
                O.OutletName,
                O.OutletNumber,
                I.InventoryID,
                I.ItemYear,
                I.InventoryItemName,
                I.InventoryNumber,
                I.ExpirationDate,
                SUM(ISNULL(SOI.QuantityOrdered, 0)) - ISNULL(SUM(CASE WHEN TD.TransactionTypeID = 5 THEN     TD.Quantity * -1
                                                                      WHEN TD.TransactionTypeID = 1 THEN     TD.Quantity * 1
                                                                      ELSE 0
                                                                 END), 0),
                '' Serials,
                MAX(CF.FeeTotal + CF.ItemSurCharge) AS Price,
                I.IsControlledInventory,
                '' Clerk
            FROM dbo.Inventory I
      INNER JOIN dbo.SupplyOrderItem SOI ON SOI.InventoryID = I.InventoryID AND ISNULL(    I.IsControlledInventory, 0) = 0 AND SOI.StatusCodeID = 77 --Shipped
      INNER JOIN dbo.SupplyOrder SO ON SO.SupplyOrderID = SOI.SupplyOrderID
      INNER JOIN dbo.Outlet O ON SO.OutletID = O.OutletID
      INNER JOIN dbo.Item It ON I.InventoryID = It.InventoryID
      INNER LOOP JOIN [dbo].[Transaction] T ON O.OutletID=T.OutletID
      INNER JOIN [dbo].[TransactionHeader] TH  ON T.[TransactionID] = TH.[TransactionID]
      INNER JOIN [dbo].[TransactionDetail] TD  ON TH.[TransactionHeaderID] = TD.[TransactionHeaderID] AND     TD.ItemID=It.ItemID
      --INNER JOIN dbo.vw_TransactionDetail TD ON TD.ItemID = It.ItemID AND TD.OutletID = O.OutletID
       LEFT JOIN dbo.#TempTableItemSaleFee AS CF ON It.ItemID = CF.ItemID
            WHERE O.AgentID = 310001 AND ( NULL IS NULL OR O.OutletID = NULL )
        GROUP BY O.AgentID,O.OutletID,O.OutletName,O.OutletNumber
                ,I.InventoryID,I.ItemYear,I.InventoryItemName,I.InventoryNumber,I.ExpirationDate,I.IsControlledInventory
  ORDER BY O.OutletNumber,O.OutletName, I.ItemYear DESC, I.InventoryNumber, I.InventoryItemName
END
GO

PRINT '[INFO] ALTERED PROCEDURE dbo.rpt_CurrentInventoryListing_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO
