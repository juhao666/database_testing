
IF OBJECT_ID('DBCodesTestResults') IS NULL
    CREATE TABLE DBCodesTestResults(
	    PKID INT NOT NULL IDENTITY(1,1),
		ProgramName1 VARCHAR(200), --sp/function name
		ElapsedTime1 INT, --seconds
		ProgramName2 VARCHAR(200),
		ElapsedTime2 INT, --seconds
		ParameterValues VARCHAR(1000),
		CreatedDT DATETIME NOT NULL DEFAULT GETDATE(),
		ModifiedDT DATETIME,
		primary key(PKID)
	);


GO

--ELECT * FROM dbo.DBCodesTestResults;