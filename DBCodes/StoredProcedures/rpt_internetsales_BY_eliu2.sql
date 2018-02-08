SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.rpt_internetsales_BY_eliu2') IS NULL
    EXEC('
          CREATE PROCEDURE dbo.rpt_internetsales_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO

ALTER PROCEDURE [dbo].[rpt_internetsales_BY_eliu2] (
    @Month INT,
    @Year INT
)
----------------------------------------------------------------------------------------
-- Description : Internet Sales Summary Report
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 01/15/2018  HFDNET-16787     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  EXECUTE [rpt_internetsales] 01,2017
----------------------------------------------------------------------------------------
AS
BEGIN
   
DECLARE @BeginDT DATETIME
DECLARE @EndDT DATETIME
DECLARE @Cancel INT
DECLARE @Void INT
DECLARE @Internet INT

IF @Month IS NULL 
BEGIN
    SET @BeginDT = CONVERT(DATETIME, CONCAT(@Year, '-01-01'))
    SET @EndDT = CONVERT(DATETIME, CONCAT(@Year, '-12-31 23:59:59'))
END
ELSE
BEGIN
    SET @BeginDT = CONVERT(DATETIME, CONCAT(@Year, '-', @Month, '-01'))
    SET @EndDT = DATEADD(SECOND, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @BeginDT) + 1, 0))
END;



SELECT  @Cancel = Cancel,@Void = Void FROM [Enum_TransactionType]
SELECT  @Internet = Internet FROM [Enum_SalesChannel]


IF OBJECT_ID('TEMPDB..#TEMPTransactionDetails') IS NOT NULL
BEGIN
    DROP TABLE #TEMPTransactionDetails
END

CREATE TABLE #TEMPTransactionDetails(
  [SalesChannelID] INT,
  [TransactionDetailID] INT,
  [TransactionTypeID] INT,
  [TransactionDetailTypeID] INT,
  [ItemID] INT,
  [Quantity]   INT
)

INSERT INTO #TEMPTransactionDetails(SalesChannelID,TransactionDetailID,TransactionTypeID,TransactionDetailTypeID,ItemID,Quantity)
SELECT
    T.[SalesChannelID]
    ,TD.[TransactionDetailID]
    ,TD.[TransactionTypeID]
    ,TD.[TransactionDetailTypeID]
    ,TD.[ItemID]
    ,TD.[Quantity]
FROM dbo.[Transaction] T
INNER LOOP JOIN [dbo].[TransactionHeader] TH
    ON T.[TransactionID] = TH.[TransactionID]
INNER JOIN [dbo].[TransactionDetail] TD
    ON TH.[TransactionHeaderID] = TD.[TransactionHeaderID]
WHERE T.[DateCreated] BETWEEN @BeginDT AND @EndDT AND T.[SalesChannelID] = @Internet AND TD.[TransactionTypeID] <> @Cancel


SELECT
     [SalesChannelName] = sc.[SalesChannelName]
    ,[ItemID] = rs.[ItemID]
    ,[ItemName] = I.[ItemName]
    ,[ItemNumber] = I.[ItemNumber]
    ,[ItemYear] = I.[ItemYear]
    ,[TransactionDetailTypeID] = rs.[TransactionDetailTypeID]
    ,[TransactionTypeID] = rs.[TransactionTypeID]
    ,[TotalSales] = rs.[TotalSaleAmount]
    ,[AgentHandlingFee] = rs.[AgentHandlingFee]
    ,[SoldQuantity] = rs.SoldQuantity
FROM (
    SELECT
         tt.[SalesChannelID]
        ,tt.[TransactionTypeID]
        ,tt.[TransactionDetailTypeID]
        ,tt.[ItemID]
        ,[SoldQuantity] = SUM(
                            CASE
                                WHEN tt.[TransactionTypeID] = @Void THEN tt.[Quantity] * -1
                                WHEN tt.[TransactionTypeID] <> @Void THEN tt.[Quantity]
                                ELSE 0
                            END)
        ,[AgentHandlingFee] = SUM(ISNULL(tsh.[AgentHandlingFee], 0))
        ,[TotalSaleAmount] = SUM(ISNULL(tsh.[TotalSaleAmount], 0))
         FROM #TEMPTransactionDetails tt
    LEFT JOIN (SELECT t.TransactionDetailID
                      ,SUM(CASE WHEN tdf.[FeeTypeID] = 11 THEN tdf.[Amount] ELSE 0 END) AS [AgentHandlingFee]
                      ,SUM(CASE WHEN tdf.[GlobalDistributionID] IS NULL THEN tdf.[Amount] ELSE 0 END) AS [TotalSaleAmount]
                FROM #TEMPTransactionDetails T
           LEFT JOIN dbo.[TransactionDetailFee] tdf ON tdf.TransactionDetailID = T.TransactionDetailID
            GROUP BY t.TransactionDetailID) tsh ON tt.TransactionDetailID = tsh.TransactionDetailID
    GROUP BY     tt.[SalesChannelID]
                ,tt.[TransactionTypeID]
                ,tt.[TransactionDetailTypeID]
                ,tt.[ItemID]
) rs
INNER JOIN dbo.[Item] I ON rs.[ItemID] = I.[ItemID]
INNER JOIN dbo.[SalesChannel] sc ON rs.[SalesChannelID] = sc.[SalesChannelID]
ORDER BY I.[ItemYear] DESC,
         I.[ItemNumber],
         I.[ItemName];
END;


GO

PRINT '[INFO] ALTERED PROCEDURE dbo.rpt_internetsales_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO
