SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.rpt_TransactionDetailByAgent_BY_eliu2') IS NULL
    EXEC('
          CREATE PROCEDURE dbo.rpt_TransactionDetailByAgent_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO

ALTER PROCEDURE [dbo].[rpt_TransactionDetailByAgent_BY_eliu2] (
    @OutletNumber CHAR(10) = NULL,
    @AgentID INT,
    @UserName VARCHAR(20) = NULL,
    @FromDate DATETIME,
    @ToDate DATETIME,
    @ReconciliationBatchID INT = NULL
)
----------------------------------------------------------------------------------------
-- Description : Transaction Detail By Agent Report
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 12/06/2017  HFDNET-16718     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  EXECUTE [rpt_TransactionDetailByAgent] '200003-089',200003,NULL,'01/01/2016','09/30/2016',NULL
----------------------------------------------------------------------------------------
AS
BEGIN
    DECLARE @BeginDateTime DATETIME --the format is mm/dd/yyyy 00:00:00
    DECLARE @EndDateTime DATETIME   --the format is mm/dd/yyyy 23:59:59 
    
    SET @BeginDateTime = CONVERT(DATETIME,CONVERT(DATE,@FromDate))
    SET @EndDateTime = DATEADD(ss,24*60*60-1,CONVERT(DATETIME,CONVERT(DATE,@ToDate)))
    
    IF OBJECT_ID('tempdb.dbo.#Transaction','U') IS NOT NULL
        DROP TABLE #Transaction
    
    CREATE TABLE #Transaction
    (
    TransactionID     INT,
    UserName          VARCHAR(20),
    DateCreated       DATETIME,
    OutletID          INT,
    Amount            MONEY,
    SalesChannelID    INT,
    OutletName        VARCHAR(50),
    OutletNumber      CHAR(10),
    AgentID           INT,
    SalesChannelName  VARCHAR(50)
    );

    DECLARE @SQL NVARCHAR(MAX)=N'
    SELECT T.TransactionID,T.UserName,T.DateCreated,T.OutletID,T.Amount,T.SalesChannelID,O.OutletName,O.OutletNumber,O.AgentID,s.SalesChannelName          
          FROM dbo.[Transaction] AS T
    INNER JOIN dbo.Outlet AS O ON T.OutletID = O.OutletID
     LEFT JOIN dbo.SalesChannel s ON s.SalesChannelID = T.SalesChannelID
         '
    DECLARE @SQLWhere NVARCHAR(MAX) = N'
    WHERE O.AgentID = @VAR1 
          AND T.[DateCreated] BETWEEN  @VAR2 AND @VAR3 '
    IF @OutletNumber IS NOT NULL
        SET @SQLWhere = @SQLWhere + N' AND O.OutletNumber = ''' + @OutletNumber +''' '
    IF @UserName IS NOT NULL
        SET @SQLWhere = @SQLWhere + N' AND T.UserName = ' + @UserName +' '
    IF @ReconciliationBatchID IS NOT NULL
        SET @SQLWhere = @SQLWhere + N' AND T.ReconciliationBatchID = ' + CONVERT(VARCHAR,@ReconciliationBatchID) +' '

    DECLARE @PAR NVARCHAR(MAX) = N'@VAR1 INT = NULL, @VAR2 DATETIME = NULL, @VAR3 DATETIME = NULL';

    SET @SQL = @SQL + @SQLWhere
    INSERT INTO #Transaction
    EXEC sp_executeSQL @stmt = @SQL, @param = @PAR, @VAR1 = @AgentID, @VAR2 = @BeginDateTime, @VAR3 = @EndDateTime
     
    --SELECT T.TransactionID,T.UserName,T.DateCreated,T.OutletID,T.Amount,T.SalesChannelID,O.OutletName,O.OutletNumber,O.AgentID,s.SalesChannelName
    --      INTO #Transaction
    --      FROM dbo.[Transaction] AS T
    --INNER JOIN dbo.Outlet AS O ON T.OutletID = O.OutletID
    -- LEFT JOIN dbo.SalesChannel s ON s.SalesChannelID = T.SalesChannelID
    --     WHERE O.AgentID = @AgentID 
    --           AND T.[DateCreated] BETWEEN @BeginDateTime AND @EndDateTime       
    --           AND (@OutletNumber IS NULL OR O.OutletNumber = @OutletNumber)
    --           AND (@UserName IS NULL OR T.UserName = @UserName)  
    --           AND (@ReconciliationBatchID IS NULL OR T.ReconciliationBatchID = @ReconciliationBatchID)
    
    --IF @@ROWCOUNT =0 
    --    BEGIN
    --        -- NO RESULT
    --        RETURN;
    --    END;
    
    SELECT
        A.Name + '(' + CAST(A.AgentID AS VARCHAR) + ')' AS AgentName
        ,T.TransactionID
        ,T.UserName
        ,CONVERT(VARCHAR(25), T.DateCreated, 101) TransactionDate
        ,CONVERT(VARCHAR(10), T.DateCreated, 108) AS TransactionTime
        ,T.DateCreated
        ,T.OutletID
        ,T.OutletName
        ,T.OutletNumber
        ,T.Amount TransactionAmount
        ,T.SalesChannelName AS SalesChannel
        ,dbo.udf_GetCustomerNameWithDefault(C.CustomerID, NULL) AS Customer
        ,dbo.[udf_GetCustomerIdentity](1, C.CustomerID) GOID
        ,I.ItemYear
        ,I.ItemName
        ,I.ItemNumber
        ,TT.TransactionTypeID
        ,TT.TransactionTypeName
        ,CASE
            WHEN TT.TransactionTypeName = 'Sale' THEN (TD.Quantity * 1)
            WHEN TT.TransactionTypeName = 'Void' THEN (TD.Quantity * -1)
            WHEN TT.TransactionTypeName = 'Cancel' THEN 0
        END Quantity
        ,TD.Quantity Qty
        ,TD.TransactionDetailID
        ,   
        CASE
            WHEN TT.TransactionTypeName = 'Sale' THEN (TD.Amount)
            WHEN TT.TransactionTypeName = 'Void' THEN (TD.Amount)
            WHEN TT.TransactionTypeName = 'Cancel' THEN 0
        END DetailAmount
        ,
        CASE
            WHEN (TT.TransactionTypeName = 'Sale' OR TT.TransactionTypeName = 'Void') THEN 
                 ISNULL([dbo].[udf_GetHandlingFeeForTransactionDetail](TD.TransactionDetailID), 0)
            WHEN TT.TransactionTypeName = 'Cancel' THEN 0
        END DFGHandlingFee
        ,MP.ManualPaymentID
        ,TD.TransactionDetailTypeID
    FROM #Transaction AS T
    INNER JOIN dbo.TransactionHeader TH ON T.TransactionID = TH.TransactionID
    INNER JOIN dbo.TransactionDetail TD ON TD.TransactionHeaderID = TH.TransactionHeaderID
    INNER JOIN dbo.TransactionType TT   ON TD.TransactionTypeID = TT.TransactionTypeID
     LEFT JOIN dbo.Customer C   ON TH.CustomerID = C.CustomerID
    INNER JOIN dbo.Item I   ON TD.ItemID = I.ItemID
    --INNER JOIN dbo.Outlet AS O  ON T.OutletID = O.OutletID
    INNER JOIN dbo.Agent AS A   ON T.AgentID = A.AgentID
     LEFT JOIN dbo.ManualPayment MP ON T.TransactionID = MP.TransactionID
      ORDER BY T.DateCreated,T.TransactionID,Customer

END;


GO

PRINT '[INFO] ALTERED PROCEDURE dbo.rpt_TransactionDetailByAgent_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO
