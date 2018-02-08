SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF (OBJECT_ID('dbo.udf_IsOutletACHDate_BY_eliu2', 'FN') IS NULL)
    EXEC('
          CREATE FUNCTION dbo.udf_IsOutletACHDate_BY_eliu2()
          RETURNS VARCHAR(1024)
          AS 
          BEGIN
              RETURN NULL;
          END
        ')
GO

ALTER FUNCTION [dbo].[udf_IsOutletACHDate_BY_eliu2] (
	@OutletID INT,
	@CurrentDate DATETIME
)
----------------------------------------------------------------------------------------
-- Description : Return a bit whether it is outlet ACH date
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
    DECLARE @DayName VARCHAR(10);
    DECLARE @MonthDate INT;
    DECLARE @SchedulePatternTypeID INT;
    DECLARE @WeekFrequency INT;
    DECLARE @MonthFrequency INT;
    DECLARE @DayFlags INT;
    DECLARE @TodaysDayFlag INT;
    DECLARE @ReturnValue BIT = 0;

    SELECT	@SchedulePatternTypeID = sp.[SchedulePatternTypeID],
            @DayName = d.[Name],
            @DayFlags = sp.[DayFlags],
            @MonthDate = sp.[DayOfMonth],
            @MonthFrequency = sp.[MonthFrequency],
            @WeekFrequency = sp.[WeekFrequency]
        FROM [dbo].[Outlet] o
  INNER JOIN [dbo].[SchedulePattern] sp ON o.[ACHSchedulePatternID] = sp.[SchedulePatternID]
   LEFT JOIN [dbo].[Day] d ON sp.[DayID] = d.[DayID]
       WHERE o.[OutletID] = @OutletID;

	/* Days of Week */
    IF @SchedulePatternTypeID = 1
    BEGIN
        SELECT	@TodaysDayFlag = d.[DayFlag]
            FROM [dbo].[Day] d
            WHERE d.[Name] = CONVERT( VARCHAR(10), DATENAME( [weekday], @CurrentDate ) );

        IF ( ISNULL( @DayFlags, 0 ) & @TodaysDayFlag ) <> 0
        BEGIN
            SET @ReturnValue = 1;
        END;
    END

	/* Weekly */
    ELSE IF @SchedulePatternTypeID = 2
    BEGIN
        IF CONVERT( VARCHAR(10), DATENAME( [weekday], @CurrentDate ) ) = @DayName
			AND DATEPART( [week], @CurrentDate ) % @WeekFrequency = 0
        BEGIN
            SET @ReturnValue = 1;
        END;
    END

	/* Monthly */
    ELSE IF @SchedulePatternTypeID = 3
    BEGIN
        IF DAY( @CurrentDate ) = @MonthDate AND MONTH( @CurrentDate ) % @MonthFrequency = 0
        BEGIN
            SET @ReturnValue = 1;
        END;
    END;

    RETURN @ReturnValue;
END;
GO

PRINT '[INFO] ALTERED FUNCTION dbo.udf_IsOutletACHDate_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO



