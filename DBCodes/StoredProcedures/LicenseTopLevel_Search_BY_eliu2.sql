SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF OBJECT_ID('dbo.LicenseTopLevel_Search_BY_eliu2') IS NULL
    EXEC ('
          CREATE PROCEDURE dbo.LicenseTopLevel_Search_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO
ALTER PROCEDURE [dbo].[LicenseTopLevel_Search_BY_eliu2]
(@SalesDateFrom                  DATETIME     = NULL,
 @SalesDateTo                    DATETIME     = NULL,
 @SalesClerkUserName             VARCHAR(20)  = NULL,
 @TransactionID                  BIGINT       = NULL,
 @LicenseID                      BIGINT       = NULL,
 @DocumentNumber                 VARCHAR(20)  = NULL, -- exact match

 @HasReprint                     BIT          = NULL,
 @HasDuplicate                   BIT          = NULL,
 @LicenseStatusCodeID            INT          = NULL,
 @IsExpired                      BIT          = NULL,
 @LicenseAncillaryDataKeyName    VARCHAR(50)  = NULL,
 @LicenseAncillaryDataValue      VARCHAR(200) = NULL,
 @HuntCode                       VARCHAR(10)  = NULL, -- exact match

	-- Outlet
 @OutletNumber                   VARCHAR(10)  = NULL,
 @OutletZipCode                  CHAR(5)      = NULL, -- exact match
 @OutletCityName                 VARCHAR(50)  = NULL, -- exact match
 @OutletCountyID                 INT          = NULL,
 @OutletStateID                  INT          = NULL,

	-- Item
 @ItemYear                       INT          = NULL,
 @ItemNumber                     CHAR(4)      = NULL, -- exact match
 @RootItemNumberID               INT          = NULL,
 @ItemClassID                    INT          = NULL,
 @ItemCategoryID                 INT          = NULL,
 @ItemSubcategoryID              INT          = NULL,
 @ItemTypeID                     INT          = NULL,
 @MasterHuntTypeID               INT          = NULL,
 @LEPermitTypeID                 INT          = NULL,
 @IsEntitlement                  BIT          = NULL,

	-- Customer
 @UseCustomerCriteria            BIT          = 0,

	-- Standard Unified Customer Criteria
 @CustomerTypeID                 INT          = NULL,
 @IdentityTypeCategoryID         INT          = NULL,
 @IdentityTypeID                 INT          = NULL,
 @IdentityValue                  VARCHAR(50)  = NULL,
 @PhysicalCityID                 INT          = NULL,
 @PhysicalStateID                INT          = NULL,
 @PhysicalCountyID               INT          = NULL,
 @PhysicalZipCode                CHAR(5)      = NULL,
 @PhysicalIsInternationalAddress BIT          = NULL, -- all, us only, international only

 @IsCAResident                   BIT          = NULL,
 @FirstName                      VARCHAR(40)  = NULL,
 @LastName                       VARCHAR(40)  = NULL,
 @Gender                         CHAR(1)      = NULL,
 @BusinessName                   VARCHAR(150) = NULL,
 @VesselName                     VARCHAR(150) = NULL
)
----------------------------------------------------------------------------------------
-- Description : license top level search
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 02/13/2018  CA-4111 CA-4169     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  exec [LicenseTopLevel_Search] @SalesDateFrom='4/20/2017',@SalesDateTo ='4/21/2017',@UseCustomerCriteria =1,@CustomerTypeID=1,@IdentityValue='1051298422'
--  Eexec [LicenseTopLevel_Search] @ItemNumber='1110',@UseCustomerCriteria =1,@CustomerTypeID=1,@IdentityValue='1051298422'
-- exec [LicenseTopLevel_Search] @SalesDateFrom='1/5/2017',@SalesDateTo ='1/5/2017',@UseCustomerCriteria =1,@CustomerTypeID=3,@LastName='P'
----------------------------------------------------------------------------------------
AS
         BEGIN
             SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--		   USE [CA]
--GO
--CREATE NONCLUSTERED INDEX [LicenseAction_NIX_ActionDate] ON [dbo].[LicenseAction] ([ActionDate]) INCLUDE ([LicenseID])
--USE [CA]
--GO
--CREATE NONCLUSTERED INDEX [CustomerIdentity_NIX_IdentityValue]
--ON [dbo].[CustomerIdentity] ([IdentityValue])
--INCLUDE ([CustomerID])
/* Meant for context free license search */

             IF OBJECT_ID('tempdb..#MatchingKeys') IS NOT NULL
                 BEGIN
                     DROP TABLE #MatchingKeys;
                 END;
             CREATE TABLE #MatchingKeys([LicenseID] INT);
             INSERT INTO #MatchingKeys
             EXEC [dbo].[DynamicSearch_LicenseTopLevel_BY_eliu2]
                  @SalesDateFrom = @SalesDateFrom,
                  @SalesDateTo = @SalesDateTo,
                  @SalesClerkUserName = @SalesClerkUserName,
                  @TransactionID = @TransactionID,
                  @LicenseID = @LicenseID,
                  @DocumentNumber = @DocumentNumber,
                  @HasReprint = @HasReprint,
                  @HasDuplicate = @HasDuplicate,
                  @LicenseStatusCodeID = @LicenseStatusCodeID,
                  @IsExpired = @IsExpired,
                  @LicenseAncillaryDataKeyName = @LicenseAncillaryDataKeyName,
                  @LicenseAncillaryDataValue = @LicenseAncillaryDataValue,
                  @HuntCode = @HuntCode,
                  @OutletNumber = @OutletNumber,
                  @OutletZipCode = @OutletZipCode,
                  @OutletCityName = @OutletCityName,
                  @OutletCountyID = @OutletCountyID,
                  @OutletStateID = @OutletStateID,
                  @ItemYear = @ItemYear,
                  @ItemNumber = @ItemNumber,
                  @RootItemNumberID = @RootItemNumberID,
                  @ItemClassID = @ItemClassID,
                  @ItemCategoryID = @ItemCategoryID,
                  @ItemSubcategoryID = @ItemSubcategoryID,
                  @ItemTypeID = @ItemTypeID,
                  @MasterHuntTypeID = @MasterHuntTypeID,
                  @LEPermitTypeID = @LEPermitTypeID,
                  @IsEntitlement = @IsEntitlement,
                  @SelectTopRowCount = NULL; --fix bug here, modified on 12/02/2018
			--since dbo.[LicenseTopLevel_Search] limits the rows to top 251, we are limiting the dynamic query as well for performance

             SELECT DISTINCT TOP 251 [LicenseID] = l.LicenseID,
                                     [CustomerID] = l.CustomerID,
                                     [ItemYear] = i.ItemYear,
                                     [ItemClassName] = ic.ItemClassName,
                                     [ItemCategoryName] = icat.ItemCategoryName,
                                     [SortOrder] = it.SortOrder,
		--[EnablingLicenseItemNumber] = dbo.udf_GetEnablingItemNumberByEnablingLicenseID( convert( int, l.EnablingLicenseID ) )
		--	+ '-'
		--	+ dbo.udf_GetEnablingItemNameByEnablingLicenseID( convert( int, l.EnablingLicenseID ) ),
		--REPLACE ABOVE LINES WITH THIS CONCATENATION AND THE LEFT JOINS BELOW TO el AND eli aliases
                                     (eli.ItemNumber+'-'+eli.ItemName) AS EnablingLicenseItemNumber,
                                     [ItemSalesTypeID] = i.ItemSalesTypeID,
                                     [ValidFrom] = l.ValidFrom,
                                     [ValidTo] = l.ValidTo,
                                     [HuntCode] = h.HuntCode,
                                     [HuntApplicationLicenseID] = hal.HuntApplicationLicenseID,
                                     [PartyNumber] = ha.PartyNumber,
                                     [Quantity] = l.Quantity,
                                     [ShortTermDaysValid] = i.ShortTermDaysValid,
                                     [ItemNumber] = i.ItemNumber,
                                     [IsLicenseReportAccepted] = i.IsLicenseReportAccepted,
                                     [EnablingLicenseID] = l.EnablingLicenseID,
                                     [HuntID] = l.HuntID,

--		--This probably could be cleaned up and simplified by avoiding the UDF call, but i want to test performance first. It doesn't appear to be innaccurate
                                     [DynamicDescription] = dbo.udf_GetLicenseDynamicDescriptionByLicenseID(CONVERT(INT, l.LicenseID)),
                                     [ItemName] = i.ItemName,
                                     [Description] = i.[Description],
                                     [PrintedDescription] = I.PrintedDescription,
                                     [Status] = sc.[Description],

--		--If the item is part of a package, it counts the child items that are part of the package. i.e. a special 2 day hunt may contain a child item pass for each hunt day
                                     [ItemPackageCount] = dbo.udf_GetItemPackageCountByItemID(i.ItemID),
                                     [Substatus] = dbo.udf_GetLastLicenseActionNameByLicenseID(CONVERT(INT, l.LicenseID)),
                                     [LastActionDate] = dbo.udf_GetLastLicenseActionDateByLicenseID(CONVERT(INT, l.LicenseID)),
                                     [ActionDate] = CONVERT(DATE, dbo.udf_GetLastLicenseActionDateByLicenseIDandLicenseActionTypeID(CONVERT(INT, l.LicenseID), 4)), --4 is for sold
/*this issue sort date loses the timestamp value by converting from datetime -> date -> datetime. Is this the desired effect?
2010-08-27 09:05:48.253 becomes 2010-08-27 becomes 2010-08-27 00:00:00.000*/

                                     [IssueDateSort] = CONVERT(DATETIME, CONVERT(DATE, dbo.udf_GetLicenseIssueDateByLicenseID(CONVERT(INT, l.LicenseID)))),
                                     [IssueDate] = dbo.udf_GetLicenseIssueDateByLicenseID(CONVERT(INT, l.LicenseID)),
                                     [Duplicate] = dbo.udf_GetLicenseDupeCountByLicenseID(CONVERT(INT, l.LicenseID)),
                                     [CustomerName] = CASE
                                                          WHEN l.CustomerID IS NOT NULL
                                                          THEN dbo.udf_GetCustomerName(l.CustomerID)
                                                          WHEN qsc.LastName IS NOT NULL
                                                          THEN COALESCE(qsc.LastName+', '+qsc.FirstName, qsc.LastName)
                                                          ELSE ''
                                                      END,
                                     [OutletName] = o.OutletName+'('+o.OutletNumber+')',
                                     DocumentNumber = CASE
                                                          WHEN la.LicenseActionTypeID = 4
                                                          THEN d.DocumentNumber
                                                          ELSE ''
                                                      END
             FROM License l
                  INNER JOIN #MatchingKeys cs ON l.LicenseID = cs.LicenseID

	--ADD TO AVOID UDF CALLS FOR ENABLING LICENSE ITEM NUMBER
                  LEFT JOIN dbo.License el ON l.EnablingLicenseID = el.LicenseID
                  LEFT JOIN dbo.Item eli ON el.ItemID = eli.ItemID
	--

                  INNER JOIN Item i ON l.ItemID = I.ItemID
                  INNER JOIN ItemClass ic ON i.ItemClassID = ic.ItemClassID
                  INNER JOIN ItemCategory icat ON i.ItemCategoryID = icat.ItemCategoryID
                  INNER JOIN ItemType it ON i.ItemTypeID = it.ItemTypeID
                  INNER JOIN StatusCode sc ON l.StatusCodeID = sc.StatusCodeID
                  CROSS JOIN Enum_LicenseActionType lat
                  INNER JOIN LicenseAction la ON la.LicenseID = l.LicenseID
                                                 AND la.LicenseActionTypeID IN(lat.Sold, lat.Issued)
                  INNER JOIN Document d ON d.DocumentID = la.DocumentID
                  INNER JOIN Outlet o ON o.OutletID = D.OutletID
                  LEFT JOIN Hunt h ON l.HuntID = h.HuntID
                  LEFT JOIN HuntApplicationLicense hal ON l.LicenseID = hal.LicenseID
                  LEFT JOIN HuntApplication ha ON hal.HuntApplicationID = ha.HuntApplicationID
                  LEFT JOIN QuickSaleCustomer qsc ON qsc.LicenseID = l.LicenseID
             WHERE(@UseCustomerCriteria = 0
                   OR l.CustomerID IN
(
    SELECT CustomerID
    FROM dbo.udf_Search_CustomerUnified(@CustomerTypeID, NULL, NULL, @IdentityTypeCategoryID, @IdentityTypeID, @IdentityValue, @PhysicalCityID, @PhysicalStateID, @PhysicalCountyID, @PhysicalZipCode, @PhysicalIsInternationalAddress, @IsCAResident, @FirstName, @LastName, @Gender, @BusinessName, @VesselName, NULL)
)) OPTION(RECOMPILE);
         END;

GO
PRINT '[INFO] ALTERED PROCEDURE dbo.LicenseTopLevel_Search_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO