SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.rpt_EventNoticeForCreditBalance_BY_eliu2') IS NULL
    EXEC('
          CREATE PROCEDURE dbo.rpt_EventNoticeForCreditBalance_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO
ALTER PROCEDURE [dbo].[rpt_EventNoticeForCreditBalance_BY_eliu2]
----------------------------------------------------------------------------------------
-- Description : Credit Balance Report
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 01/16/2018  HFDNET-16786     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  EXECUTE  dbo.[rpt_EventNoticeForCreditBalance]
----------------------------------------------------------------------------------------
AS
BEGIN
    SELECT  A.AgentID,
            A.Name AS AgentName,
            ( ABA.BankName + ' / Account #: ******' + RIGHT(ABA.AccountNumber, 4) ) AS Bank,
            SUM(AOH.OutstandingAmount) OutstandingAmount,
            COUNT(AOH.JournalID) JournalCount
      FROM dbo.vw_AgentAndOutletForACH_BY_eliu2 AOH
 LEFT JOIN dbo.Agent A ON AOH.AgentID = A.AgentID
INNER JOIN dbo.AgentBankAccount ABA ON AOH.AgentBankAccountID = ABA.AgentBankAccountID
  GROUP BY AOH.AgentBankAccountID,
             A.AgentID,
             A.Name,
           ABA.BankName,
           ABA.AccountNumber
    HAVING SUM(OutstandingAmount) <= 0
  ORDER BY A.AgentID
END
GO
PRINT '[INFO] ALTERED PROCEDURE dbo.rpt_CurrentInventoryListing_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO
