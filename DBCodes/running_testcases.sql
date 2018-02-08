/*
The execution order is:
1.Tables
2.UserFunctions
3.StoredProcedures
4.TestCases
*/

SET NOCOUNT ON  

--USE [DATABASENAME]
--Table
:r .\Tables\DBCodesTestResults.sql
--Vies
:r .\Views\vw_AgentAndOutletForACH_BY_eliu2.sql

--User Defined Function
:r .\UserFunctions\udf_CurrentOrPreviousStatementbyJournalID_BY_eliu2.sql
:r .\UserFunctions\udf_GetJournalBankAccountID_BY_eliu2.sql
:r .\UserFunctions\udf_GetGlobalDistribution_BY_eliu2.sql
:r .\UserFunctions\udf_IsOutletACHDate_BY_eliu2.sql

--Stored Procedure
:r .\StoredProcedures\rpt_PercentageOfRevenue_BY_eliu2.sql
:r .\StoredProcedures\rpt_StatementDetailTotals_BY_eliu2.sql
:r .\StoredProcedures\rpt_TransactionDetailByAgent_BY_eliu2.sql
:r .\StoredProcedures\rpt_CurrentInventoryListing_BY_eliu2.sql
:r .\StoredProcedures\rpt_internetsales_BY_eliu2.sql
:r .\StoredProcedures\rpt_EventNoticeForCreditBalance_BY_eliu2.sql

--Test Case
--:r .\TestCases\TC_rpt_PercentageOfRevenue.sql
--:r .\TestCases\TC_rpt_StatementDetailTotals.sql
--:r .\TestCases\TC_rpt_TransactionDetailByAgent.sql