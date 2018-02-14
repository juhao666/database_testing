SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF OBJECT_ID('dbo.DynamicSearch_LicenseTopLevel_BY_eliu2') IS NULL
    EXEC ('
          CREATE PROCEDURE dbo.DynamicSearch_LicenseTopLevel_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO
ALTER PROCEDURE [dbo].[DynamicSearch_LicenseTopLevel_BY_eliu2]
(@SalesDateFrom               DATETIME     = NULL,
 @SalesDateTo                 DATETIME     = NULL,
 @SalesClerkUserName          VARCHAR(20)  = NULL,
 @TransactionID               BIGINT       = NULL,
 @LicenseID                   BIGINT       = NULL,
 @DocumentNumber              VARCHAR(20)  = NULL, -- exact match

 @HasReprint                  BIT          = NULL,
 @HasDuplicate                BIT          = NULL,
 @LicenseStatusCodeID         INT          = NULL,
 @IsExpired                   BIT          = NULL,
 @LicenseAncillaryDataKeyName VARCHAR(50)  = NULL,
 @LicenseAncillaryDataValue   VARCHAR(200) = NULL,
 @HuntCode                    VARCHAR(10)  = NULL, -- exact match

	-- Outlet
 @OutletNumber                VARCHAR(10)  = NULL,
 @OutletZipCode               CHAR(5)      = NULL, -- exact match
 @OutletCityName              VARCHAR(50)  = NULL, -- exact match
 @OutletCountyID              INT          = NULL,
 @OutletStateID               INT          = NULL,

	-- Item
 @ItemYear                    INT          = NULL,
 @ItemNumber                  CHAR(4)      = NULL, -- exact match
 @RootItemNumberID            INT          = NULL,
 @ItemClassID                 INT          = NULL,
 @ItemCategoryID              INT          = NULL,
 @ItemSubcategoryID           INT          = NULL,
 @ItemTypeID                  INT          = NULL,
 @MasterHuntTypeID            INT          = NULL,
 @LEPermitTypeID              INT          = NULL,
 @IsEntitlement               BIT          = NULL,
 @SelectTopRowCount           INT          = NULL
)
AS
         BEGIN
             SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Final SQL statement will be stored in @sql
             DECLARE @sql NVARCHAR(MAX), @select NVARCHAR(MAX), @from NVARCHAR(MAX), @Where NVARCHAR(MAX);

--Each query parameter for the dynamic sql must be defined in @params with a different name than the proc parameter
             DECLARE @params NVARCHAR(MAX)= N'
		  @iSalesDateFrom datetime = null
		, @iSalesDateTo datetime = null
		, @iSalesClerkUserName varchar(20) = null
		, @iTransactionID bigint = null
		, @iLicenseID bigint = null
		, @iDocumentNumber varchar(20) = null
		, @iHasReprint bit = null
		, @iHasDuplicate bit = null
		, @iLicenseStatusCodeID int = null
		, @iIsExpired bit = null
		, @iLicenseAncillaryDataKeyName varchar(50) = null
		, @iLicenseAncillaryDataValue varchar(200) = null
		, @iHuntCode varchar(10) = null
		, @iOutletNumber varchar(10) = null
		, @iOutletZipCode char(5) = null
		, @iOutletCityName varchar(50) = null
		, @iOutletCountyID int = null
		, @iOutletStateID int = null
		, @iItemYear int = null
		, @iItemNumber char(4) = null
		, @iRootItemNumberID int = null
		, @iItemClassID int = null
		, @iItemCategoryID int = null
		, @iItemSubcategoryID int = null
		, @iItemTypeID int = null
		, @iMasterHuntTypeID int = null
		, @iIsEntitlement bit = null
		, @iLEPermitTypeID int = null
		, @iSelectTopRowCount int = null';

--Select clause
             IF(@SelectTopRowCount IS NOT NULL)
                 BEGIN
                     SET @select = N'   SELECT TOP '+CAST(@SelectTopRowCount AS VARCHAR(10))+' l.licenseID';
                 END;
                 ELSE
             SET @select = N'   SELECT l.licenseID';
             SET @from = N'
     FROM dbo.License l';
             SET @where = N'
    WHERE 1=1';
             IF(@LicenseID IS NOT NULL)
                 BEGIN
                     SET @where = @where+' AND l.LicenseID = @iLicenseID';
                 END;
             IF(@LicenseStatusCodeID IS NOT NULL)
                 BEGIN
                     SET @where = @where+' AND l.StatusCodeID = @iLicenseStatusCodeID';
                 END;
             IF(@IsExpired = 1)
                 BEGIN
                     SET @where = @where+' AND l.ValidTo < dbo.udf_GetCurrentDateTime()';
                 END;
             IF(@IsExpired = 0)
                 BEGIN
                     SET @where = @where+' AND l.ValidTo >= dbo.udf_GetCurrentDateTime()';
                 END;
             IF COALESCE(@ItemYear, @RootItemNumberID, @ItemClassID, @ItemCategoryID, @ItemSubcategoryID, @ItemTypeID, @MasterHuntTypeID, @ItemNumber, @IsEntitlement) IS NOT NULL
                 BEGIN
		--SET @from = @from + ' JOIN dbo.Item i on l.ItemID = i.ItemID'
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.Item i WHERE l.ItemID = i.ItemID';
                     IF(@ItemYear IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.ItemYear = @iItemYear';
                         END;
                     IF(@ItemNumber IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.ItemNumber = @iItemNumber';
                         END;
                     IF(@RootItemNumberID IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.RootItemNumberID = @iRootItemNumberID';
                         END;
                     IF(@ItemClassID IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.ItemClassID = @iItemClassID';
                         END;
                     IF(@ItemCategoryID IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.ItemCategoryID = @iItemCategoryID';
                         END;
                     IF(@ItemSubcategoryID IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.ItemSubcategoryID = @iItemSubcategoryID';
                         END;
                     IF(@ItemtypeID IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND i.ItemTypeID = @iItemTypeID';
                         END;
                     IF(@IsEntitlement IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.ItemType it WHERE i.ItemTypeID = it.ItemTypeID AND it.IsEntitlement = @iIsEntitlement)';
                         END;
                     IF(@MasterHuntTypeID IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.HuntTypeLicenseYear htly WHERE i.HuntTypeLicenseYearID = htly.HuntTypeLicenseYearID AND htly.MasterHuntTypeID = @iMasterHuntTypeID)';
                         END;
                     SET @where = @where+')';
                 END;
             IF(@HuntCode IS NOT NULL)
--h.HuntCode logic supports wildcard, but UI should NOT default to begins with
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.Hunt h WHERE l.HuntID = h.HuntID AND h.HuntCode like @iHuntCode) ';
                     SET @where = @where+'  OR EXISTS (SELECT 1 FROM dbo.Item i WHERE l.ItemID = i.ItemID
				                            AND EXISTS (SELECT 1 FROM dbo.HuntActivity ha WHERE i.HuntActivityID = ha.HuntActivityID AND ha.ActivityCode like @iHuntCode)
											) ';
                 END;

--IF (@HasDuplicate) IS NOT NULL
--BEGIN

--left join (select DISTINCT la_duplicate.LicenseID
--						from dbo.LicenseAction la_duplicate
--						join dbo.Enum_LicenseActionType lat_duplicate
--						  on la_duplicate.LicenseActionTypeID = lat_duplicate.Duplicated) dupe on l.LicenseID = dupe.LicenseID'
             IF(@HasDuplicate = 0)
                 BEGIN
                     SET @where = @where+' AND NOT EXISTS (SELECT 1 FROM dbo.LicenseAction la_duplicate
		                    JOIN dbo.Enum_LicenseActionType lat_duplicate ON la_duplicate.LicenseActionTypeID = lat_duplicate.Duplicated
							WHERE l.LicenseID = la_duplicate.LicenseID)';
                 END;
             IF(@HasDuplicate = 1)
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.LicenseAction la_duplicate
		                    JOIN dbo.Enum_LicenseActionType lat_duplicate ON la_duplicate.LicenseActionTypeID = lat_duplicate.Duplicated
							WHERE l.LicenseID = la_duplicate.LicenseID)';
                 END;

--END


             IF(@HasReprint = 0)
                 BEGIN
                     SET @where = @where+' AND NOT EXISTS (SELECT 1
		from dbo.LicenseAction la_reprint
		join dbo.Enum_LicenseActionType lat_reprint on la_reprint.LicenseActionTypeID = lat_reprint.Reprinted
		WHERE l.LicenseID = la_reprint.LicenseID)';
                 END;
             IF(@HasReprint = 1)
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1
		from dbo.LicenseAction la_reprint
		join dbo.Enum_LicenseActionType lat_reprint on la_reprint.LicenseActionTypeID = lat_reprint.Reprinted
		WHERE l.LicenseID = la_reprint.LicenseID)';
                 END;
             IF(COALESCE(@DocumentNumber, @OutletCityName, @OutletNumber, @SalesClerkUserName) IS NOT NULL	--varchar datatypes
                OR COALESCE(@OutletStateID, @OutletCountyID) IS NOT NULL	--int datatypes
                OR COALESCE(@SalesDateFrom, @SalesDateTo) IS NOT NULL --datetime datatypes
                OR @TransactionID IS NOT NULL --bigint datatype
                OR @OutletZipCode IS NOT NULL) --char datatype
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.LicenseAction la WHERE l.LicenseID = la.LicenseID'; --POS 1; ')' NEEDED

                     IF @SalesDateFrom IS NOT NULL
                         BEGIN
                             SET @where = @where+' AND la.ActionDate >= @iSalesDateFrom';
                         END;
                     IF(@SalesDateTo IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND la.ActionDate < dateadd(d, 1, @iSalesDateTo)';
                         END;
                     IF(@DocumentNumber IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.Document d WHERE la.DocumentID = d.DocumentID AND d.DocumentNumber = @iDocumentNumber)';
                         END;
                     IF(COALESCE(@OutletCityName, @OutletNumber, @SalesClerkUserName) IS NOT NULL	--varchar datatypes
                        OR COALESCE(@OutletStateID, @OutletCountyID) IS NOT NULL	--int datatypes
                        OR @TransactionID IS NOT NULL --bigint datatype
                        OR @OutletZipCode IS NOT NULL)
                         BEGIN
                             SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.TransactionDetail td
				                                         JOIN dbo.TransactionHeader th on td.TransactionHeaderID = th.TransactionHeaderID
				                                         JOIN dbo.[Transaction] t on th.TransactionID = t.TransactionID
														WHERE la.TransactionDetailID = td.TransactionDetailID';  --POS 2; ')' NEEDED

                             IF(@SalesClerkUserName IS NOT NULL)
                                 BEGIN
                                     SET @where = @where+' AND t.UserName = @iSalesClerkUserName'; --exact match
                                 END;
                             IF(@TransactionID IS NOT NULL)
                                 BEGIN
                                     SET @where = @where+' AND t.TransactionID = @iTransactionID';
                                 END;
                             IF(COALESCE(@OutletCityName, @OutletNumber) IS NOT NULL
                                OR COALESCE(@OutletStateID, @OutletCountyID) IS NOT NULL
                                OR @OutletZipCode IS NOT NULL)
                                 BEGIN
                                     SET @where = @where+' AND EXISTS (SELECT 1 FROM  dbo.Outlet o WHERE t.OutletID = o.OutletID'; --POS 3; ')' NEEDED
                                     IF(@OutletNumber IS NOT NULL)
                                         BEGIN
                                             SET @where = @where+' AND o.OutletNumber like @iOutletNumber'; -- supports wildcard
                                         END;
                                     IF(@OutletCityName IS NOT NULL
                                        OR COALESCE(@OutletStateID, @OutletCountyID) IS NOT NULL
                                        OR @OutletZipCode IS NOT NULL)
                                         BEGIN
                                             SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.AddressDetail obad WHERE o.BusinessAddressID = obad.AddressID and obad.IsActive = 1'; -- Active Outlet Business Address Detail
								--POS 4; ')' NEEDED
                                             IF(@OutletStateID IS NOT NULL)
                                                 BEGIN
                                                     SET @where = @where+' AND obad.StateID = @iOutletStateID';
                                                 END;
                                             IF(@OutletCityName IS NOT NULL)
                                                 BEGIN
                                                     SET @where = @where+' AND EXISTS (SELECT 1  FROM dbo.City obc	WHERE obad.CityID = obc.CityID  AND obc.[Name] = @iOutletCityName)'; --exact match
                                                 END;
                                             IF(@OutletCountyID IS NOT NULL)
                                                 BEGIN
                                                     SET @where = @where+' AND EXISTS (SELECT 1  FROM ZipCode obzc	WHERE obad.ZipCodeID = obzc.ZipCodeID AND obzc.CountyID = @iOutletCountyID)';
                                                 END;
                                             IF(@OutletZipCode IS NOT NULL)
                                                 BEGIN
                                                     SET @where = @where+' AND EXISTS (SELECT 1  FROM ZipCode obzc	WHERE obad.ZipCodeID = obzc.ZipCodeID AND obzc.ZipCode = @iOutletZipCode )';
                                                 END;
                                             SET @where = @where+')';	--')' POS 4
                                         END;
                                     SET @where = @where+')'; -- ')' POS 3
                                 END;
                             SET @where = @where+')'; -- ')' POS 2
                         END;
                     SET @where = @where+')'; -- ')' POS 1
                 END;
             IF(@LEPermitTypeID IS NOT NULL)
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.LEPermit lep WHERE l.LEPermitID = lep.LEPermitID AND lep.LEPermitTypeID = @iLEPermitTypeID)';
                 END;
             IF(@LicenseAncillaryDataValue IS NOT NULL)
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.LicenseAncillaryData lad WHERE l.LicenseID = lad.LicenseID AND lad.DataValue like @iLicenseAncillaryDataValue)'; -- supports wildcard
                 END;
             IF(@LicenseAncillaryDataKeyName IS NOT NULL)
                 BEGIN
                     SET @where = @where+' AND EXISTS (SELECT 1 FROM dbo.LicenseAncillaryData lad WHERE l.LicenseID = lad.LicenseID
			                    AND EXISTS (SELECT 1 FROM dbo.LicenseAncillaryDataKey ladk WHERE lad.LicenseAncillaryDataKeyID = ladk.LicenseAncillaryDataKeyID
										    AND ladk.[Name] = @iLicenseAncillaryDataKeyName
											)
										)'; -- exact match (comes from drop down)
                 END;
             SET @sql = @select+@from+@where+' OPTION(RECOMPILE)';
             --PRINT @sql;
             EXEC dbo.sp_executesql
                  @sql,
                  @params,
                  @iSalesDateFrom = @SalesDateFrom,
                  @iSalesDateTo = @SalesDateTo,
                  @iSalesClerkUserName = @SalesClerkUserName,
                  @iTransactionID = @TransactionID,
                  @iLicenseID = @LicenseID,
                  @iDocumentNumber = @DocumentNumber,
                  @iHasReprint = @HasReprint,
                  @iHasDuplicate = @HasDuplicate,
                  @iLicenseStatusCodeID = @LicenseStatusCodeID,
                  @iIsExpired = @IsExpired,
                  @iLicenseAncillaryDataKeyName = @LicenseAncillaryDataKeyName,
                  @iLicenseAncillaryDataValue = @LicenseAncillaryDataValue,
                  @iHuntCode = @HuntCode,
                  @iOutletNumber = @OutletNumber,
                  @iOutletZipCode = @OutletZipCode,
                  @iOutletCityName = @OutletCityName,
                  @iOutletCountyID = @OutletCountyID,
                  @iOutletStateID = @OutletStateID,
                  @iItemYear = @ItemYear,
                  @iItemNumber = @ItemNumber,
                  @iRootItemNumberID = @RootItemNumberID,
                  @iItemClassID = @ItemClassID,
                  @iItemCategoryID = @ItemCategoryID,
                  @iItemSubcategoryID = @ItemSubcategoryID,
                  @iItemTypeID = @ItemTypeID,
                  @iMasterHuntTypeID = @MasterHuntTypeID,
                  @iIsEntitlement = @IsEntitlement,
                  @iLEPermitTypeID = @LEPermitTypeID,
                  @iSelectTopRowCount = @SelectTopRowCount;
         END;
GO

PRINT '[INFO] ALTERED PROCEDURE dbo.DynamicSearch_LicenseTopLevel_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO

