SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.rpt_StatementDetailTotals_BY_eliu2') IS NULL
    EXEC('
          CREATE PROCEDURE dbo.rpt_StatementDetailTotals_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO

ALTER PROCEDURE [dbo].[rpt_StatementDetailTotals_BY_eliu2] (
     @AgentID INT,
     @OutletID CHAR(10),
     @StatementDate DATETIME,
     @AgentBankAccountID INT
    )
----------------------------------------------------------------------------------------
-- Description : Statement Detail Total Report
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 12/04/2017  HFDNET-16718     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  EXECUTE [rpt_StatementDetailTotals] 200003,'200003-089','10/06/2015',84
----------------------------------------------------------------------------------------
AS

BEGIN
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MatchDate DATE;
DECLARE @BeginTime DATETIME;
DECLARE @EndTime DATETIME;


SELECT TOP 1 @MatchDate = CONVERT( DATE, s.[DateCreated])
  FROM [dbo].[Statement] s
 WHERE s.AgentID = @AgentID AND s.DateCreated < DATEADD(DAY,1,@StatementDate)
 ORDER BY s.DateCreated DESC


IF @MatchDate IS NULL
    BEGIN       
        RETURN 
    END;

SET @Begintime = CONVERT(DATETIME,@MatchDate) --'MM/DD/YYYY 00:00:00'
SET @Endtime = DATEADD(ss,24*60*60-1,@Begintime) --'MM/DD/YYYY 23:59:59'

--SELECT @BeginTime,@EndTime

IF OBJECT_ID('TEMPDB..#Statement','U') IS NOT NULL
    DROP TABLE #Statement;

CREATE TABLE #Statement
(StatementID INT,
 OutletID INT,
 AgentID INT,
 DateCreated DATETIME
);

INSERT INTO #Statement(StatementID,OutletID,AgentID,DateCreated)
SELECT s.StatementID,s.OutletID,s.AgentID,s.DateCreated
  FROM [dbo].[Statement] s
 WHERE s.AgentID = @AgentID AND s.DateCreated BETWEEN @Begintime AND @Endtime

SELECT S.AgentID,
       S.OutletID,
       CASE WHEN O.OutletNumber IS NULL OR O.OutletNumber <> @OutletID THEN 
                 JST.JournalAmount -- OtherOutletAmount,
            WHEN O.OutletNumber = @OutletID THEN
                 0
            ELSE -1
       END AS OtherOutletAmount,
       CASE WHEN O.OutletNumber IS NULL OR O.OutletNumber <> @OutletID THEN 
                 0
            WHEN O.OutletNumber = @OutletID THEN
                 JST.JournalAmount
            ELSE -1
       END AS OutletAmount,       
       DATEADD([day], 3, @Begintime) AS StmtDate,
       [dbo].[udf_GetJournalBankAccountID](J.JournalID, S.StatementID) AgentBankAccountID,
       [dbo].[udf_GetJournalBankAccount](J.JournalID, S.StatementID) BankAccount,
       [dbo].[udf_GetRoutingNumberAccountNumberByJournal](J.JournalID, S.StatementID) AccountNumber
        FROM dbo.Journal AS J  
   LEFT JOIN dbo.Outlet O  ON J.OutletID = O.OutletID
  INNER JOIN dbo.JournalStatement AS JST ON J.JournalID = JST.JournalID
  INNER JOIN #Statement S ON JST.StatementID = S.StatementID   
       WHERE ( S.AgentID = @AgentID )                   
            AND ( [dbo].[udf_GetJournalBankAccountID](J.JournalID, S.StatementID) = @AgentBankAccountID )            
END


GO

PRINT '[INFO] ALTERED PROCEDURE dbo.rpt_StatementDetailTotals_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO
