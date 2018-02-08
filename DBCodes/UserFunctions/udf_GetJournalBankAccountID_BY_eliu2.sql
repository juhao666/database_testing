SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF (OBJECT_ID('dbo.udf_GetJournalBankAccountID_BY_eliu2', 'FN') IS NULL)
    EXEC('
          CREATE FUNCTION dbo.udf_GetJournalBankAccountID_BY_eliu2()
          RETURNS VARCHAR(1024)
          AS 
          BEGIN
              RETURN NULL;
          END
        ')
GO

ALTER FUNCTION [dbo].[udf_GetJournalBankAccountID_BY_eliu2] (
    @JournalID INT, 
    @StatementID INT
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
--  
----------------------------------------------------------------------------------------
RETURNS INT
AS
BEGIN
    DECLARE @CurrentDateTime DATETIME = [dbo].[udf_GetCurrentDateTime]();

    /*
        The relationship between journals and Statements is many to many.  Originally this function 
        only took a JournalID, but that couldn't return the correct BankAccount through statement history.
        If this journal is associated with an outlet (has an OutletID), get it's associated OutletPaymentMethod according to the 
        Statement's DateCreated.  If there isn't an associated statement, get the outlet's effective payment as of now.

        If it wasn't tied to an outlet, or there was no OutletPaymentMethod effective, get the agent bank account
        based on the Journal's ACHBatchDetailID

        If that's null, default to the primary bank account of the Journal's Agent.
    */

    RETURN COALESCE(
            /*
                If there's an OutletID tied to this Journal, get the OutletPaymentMethod's BankAccount
                based on the Statement's Created date (if available), otherwise get the OutletPayment based on now.
            */
            (

             SELECT TOP 1 [AgentBankAccountID] = opm.[AgentBankAccountID]
               FROM [dbo].[Journal] j
              INNER JOIN [dbo].[JournalStatement] js ON j.[JournalID] = js.[JournalID]
              INNER JOIN [dbo].[Statement] s ON js.[StatementID] = s.[StatementID]
              INNER JOIN [dbo].[OutletPaymentMethod] opm ON j.[OutletID] = opm.[OutletID]
                   WHERE j.[JournalID] = @JournalID
                        AND s.[StatementID] = @StatementID                      
                        AND opm.[EffectiveDate] < s.[DateCreated]                                                    
                ORDER BY opm.[EffectiveDate] DESC
            ),
            /*
                If it wasn't an outlet id, there is no "effective/history" tables for Agent charges. So, first
                try to get the historically accurate AgentBankAccountID through the Journal's ACHBatchDetailID
            */
            /* If there isn't an ACHBatchDetail associated, default to the primary agent bank account */
            (
            SELECT TOP 1 [AgentBankAccountID]=COALESCE(achbd.[AgentBankAccountID],aba.[AgentBankAccountID])
            FROM [dbo].[Journal] j
            LEFT JOIN [dbo].[ACHBatchDetail] achbd ON j.[ACHBatchDetailID] = achbd.[ACHBatchDetailID]
            LEFT JOIN [dbo].[AgentBankAccount] aba  ON j.[AgentID] = aba.[AgentBankAccountID] AND aba.[IsPrimaryAccount] = 1
            WHERE j.[JournalID] = @JournalID
            ),
            /* Otherwise, there is no bank account. */
            CONVERT( INT, NULL )
        );
END;

GO
PRINT '[INFO] ALTERED FUNCTION dbo.udf_GetJournalBankAccountID_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO



