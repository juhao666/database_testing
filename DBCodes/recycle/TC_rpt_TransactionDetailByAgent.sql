----------------------------------------------------------------------------------------
-- Description : Test Case for rpt_TransactionDetailByAgent
-- Author      : eliu2

-- History     :
-- DATE        AUTHOR          DESCRIPTION
-- ----------  ----------      ---------------------------------------------------------
-- 01/02/2018  eliu2           initial
----------------------------------------------------------------------------------------

DECLARE @BEGINTIME DATETIME
DECLARE @ENDTIME DATETIME
DECLARE @ELAPSEDTIME INT--SECONDS
DECLARE @NEWID INT
DECLARE @RS TABLE(
    COL1   NVARCHAR(200),
    COL2   NVARCHAR(200),
    COL3   NVARCHAR(200),
    COL4   NVARCHAR(200),
    COL5   NVARCHAR(200),
    COL6   NVARCHAR(200),
    COL7   NVARCHAR(200),
    COL8   NVARCHAR(200),
    COL9   NVARCHAR(200),
    COL10  NVARCHAR(200),
    COL11  NVARCHAR(200),
    COL12  NVARCHAR(200),
    COL13  NVARCHAR(200),
    COL14  NVARCHAR(200),
    COL15  NVARCHAR(200),
    COL16  NVARCHAR(200),
    COL17  NVARCHAR(200),
    COL18  NVARCHAR(200),
    COL19  NVARCHAR(200),
    COL20  NVARCHAR(200),
    COL21  NVARCHAR(200),
    COL22  NVARCHAR(200),
    COL23  NVARCHAR(200),
    COL24  NVARCHAR(200),
    COL25  NVARCHAR(200))

/*Test Program after optimization*/
SET @BEGINTIME = GETDATE()
/*TODO:An INSERT EXEC statement cannot be nested.*/
INSERT INTO @RS EXECUTE [dbo].rpt_TransactionDetailByAgent_BY_eliu2 '200003-089',200003,NULL,'01/01/2016','09/30/2016',NULL
SET @ENDTIME = GETDATE()
SET @ELAPSEDTIME = DATEDIFF(SS,@BEGINTIME,@ENDTIME)

INSERT INTO DBCodesTestResults(ProgramName1,ElapsedTime1,ParameterValues)
VALUES('rpt_TransactionDetailByAgent_BY_eliu2',@ELAPSEDTIME,'''200003-089'',200003,NULL,''01/01/2016'',''09/30/2016'',NULL')

SET  @NEWID = SCOPE_IDENTITY()

DELETE FROM @RS 

/*Test Program before optimization*/
SET @BEGINTIME = GETDATE()
INSERT INTO @RS EXECUTE [dbo].rpt_TransactionDetailByAgent '200003-089',200003,NULL,'01/01/2016','09/30/2016',NULL
SET @ENDTIME = GETDATE()
SET @ELAPSEDTIME = DATEDIFF(SS,@BEGINTIME,@ENDTIME)

UPDATE DBCodesTestResults 
SET ProgramName2='rpt_TransactionDetailByAgent'
    ,ElapsedTime2 = @ELAPSEDTIME
    ,ModifiedDT = GETDATE()
WHERE PKID= @NEWID

PRINT 'Test Case successfully completed!'



GO
