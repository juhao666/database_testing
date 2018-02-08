SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF (OBJECT_ID('dbo.udf_IsAgentOutletACHDate_BY_eliu2', 'FN') IS NULL)
    EXEC('
          CREATE FUNCTION dbo.udf_IsAgentOutletACHDate_BY_eliu2()
          RETURNS VARCHAR(1024)
          AS 
          BEGIN
              RETURN NULL;
          END
        ')
GO

ALTER FUNCTION [dbo].[udf_IsAgentOutletACHDate_BY_eliu2] (
     @AgentID INT,
     @CurrentDate DATETIME
    )
----------------------------------------------------------------------------------------
-- Description : Return a bit whether it is angent and outlet ACH date
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 01/16/2018  HFDNET-16786     eliu2           SQL Tuning
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  
----------------------------------------------------------------------------------------
RETURNS BIT
BEGIN
DECLARE @ReturnValue BIT =0 

IF EXISTS (SELECT 1 FROM dbo.Outlet WHERE AgentID = @AgentID AND dbo.udf_IsOutletACHDate_BY_eliu2(OutletID,@CurrentDate)=1)
BEGIN
    SET @ReturnValue = 1
END
RETURN @ReturnValue
END
GO

PRINT '[INFO] ALTERED FUNCTION dbo.udf_IsAgentOutletACHDate_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO