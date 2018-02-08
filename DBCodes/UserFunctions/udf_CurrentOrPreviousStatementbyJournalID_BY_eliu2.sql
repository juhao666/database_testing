SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF (OBJECT_ID('dbo.udf_CurrentOrPreviousStatementbyJournalID_BY_eliu2', 'FN') IS NULL)
    EXEC('
          CREATE FUNCTION dbo.udf_CurrentOrPreviousStatementbyJournalID_BY_eliu2()
          RETURNS VARCHAR(1024)
          AS 
          BEGIN
              RETURN NULL;
          END
        ')
GO

ALTER FUNCTION [dbo].[udf_CurrentOrPreviousStatementbyJournalID_BY_eliu2] (
	@JournalID INT,
	@DateTocheck DATETIME
)
----------------------------------------------------------------------------------------
-- Description : Get CURRENT or PREVIOUS Statement BY JournalID
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 12/18/2017  HFDNET-16896     eliu2           SQL Tuning
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  
----------------------------------------------------------------------------------------
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @CurrentPrevious VARCHAR(50) = NULL;

	SET @DateTocheck =  DATEADD(SS,-1,CONVERT(DATETIME,DATEADD(DAY,1,CONVERT(DATE,@DateTocheck))))  --'MM/DD/YYYY 23:59:59'

	SELECT @CurrentPrevious = CASE WHEN  COUNT(*) >1 THEN 'Outstanding Charges from Previous Statements' ELSE 'Current Charges' END 
    FROM [dbo].[JournalStatement] JS WHERE JS.[JournalID] = @JournalID aND JS.[DateCreated]  <= @DateTocheck

	RETURN @CurrentPrevious;
END;
GO

PRINT '[INFO] ALTERED FUNCTION dbo.udf_CurrentOrPreviousStatementbyJournalID_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO

