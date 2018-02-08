----------------------------------------------------------------------------------------
-- Description : Test Case for rpt_PercentageOfRevenue
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
/*Test Program after optimization*/
SET @BEGINTIME = GETDATE()
EXECUTE [dbo].rpt_PercentageOfRevenue_BY_eliu2 '01/01/2017', '01/31/2017', 20
SET @ENDTIME = GETDATE()
SET @ELAPSEDTIME = DATEDIFF(SS,@BEGINTIME,@ENDTIME)

INSERT INTO DBCodesTestResults(ProgramName1,ElapsedTime1,ParameterValues)
VALUES('rpt_PercentageOfRevenue_BY_eliu2',@ELAPSEDTIME,'''01/01/2017'', ''01/31/2017'', 20')

SET  @NEWID = SCOPE_IDENTITY()

/*Test Program before optimization*/
SET @BEGINTIME = GETDATE()
EXECUTE [dbo].rpt_PercentageOfRevenue '01/01/2017', '01/31/2017', 20
SET @ENDTIME = GETDATE()
SET @ELAPSEDTIME = DATEDIFF(SS,@BEGINTIME,@ENDTIME)

UPDATE DBCodesTestResults 
SET ProgramName2='rpt_PercentageOfRevenue'
    ,ElapsedTime2 = @ELAPSEDTIME
    ,ModifiedDT = GETDATE()
WHERE PKID= @NEWID

PRINT 'Test Case successfully completed!'


GO

