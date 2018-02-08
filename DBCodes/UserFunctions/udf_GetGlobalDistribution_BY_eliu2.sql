SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
IF (OBJECT_ID('dbo.udf_GetGlobalDistribution_BY_eliu2', 'IF') IS NULL)
    EXEC('
          CREATE FUNCTION dbo.udf_GetGlobalDistribution_BY_eliu2()
          RETURNS TABLE
          AS RETURN (SELECT NULL NA)
        ')
GO

ALTER FUNCTION [dbo].[udf_GetGlobalDistribution_BY_eliu2]
(@FeeTypeID INT, 
 @CurrentDate DATETIME
)
----------------------------------------------------------------------------------------
-- Description : 
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 01/09/2018  HFDNET-16782     eliu2           SQL Tuning
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  
----------------------------------------------------------------------------------------
RETURNS TABLE 
AS
RETURN
(SELECT TOP 1
    FeeAmount
    ,FeePercentage
    ,FeeCapAmount
    ,RoundToNearest
FROM dbo.GlobalDistribution
WHERE FeeTypeID = @FeeTypeID
AND EffectiveDate <= @CurrentDate
ORDER BY GlobalDistributionID DESC
)

GO
PRINT '[INFO] ALTERED FUNCTION dbo.udf_GetGlobalDistribution_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO

