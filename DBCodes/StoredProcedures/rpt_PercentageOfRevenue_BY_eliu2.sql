SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.rpt_PercentageOfRevenue_BY_eliu2') IS NULL
    EXEC('
          CREATE PROCEDURE dbo.rpt_PercentageOfRevenue_BY_eliu2
          AS
             DECLARE @error_message NVARCHAR(2000);
             SET @error_message = ''Stored procedure ''+OBJECT_NAME(@@PROCID)+'' not yet implemented'';
             RAISERROR(@error_message, 16, 1);
        ');
GO

ALTER PROCEDURE [dbo].[rpt_PercentageOfRevenue_BY_eliu2] (
    @FromDate DATETIME,
    @ToDate DATETIME,
    @POR DECIMAL(18,2)
)
----------------------------------------------------------------------------------------
-- Description : Percentage of Revenue
-- Author      :

-- History     :
-- DATE        JIRA             AUTHOR          DESCRIPTION
-- ----------  --------------   ----------      ---------------------------------------
-- 11/24/2017  HFDNET-16642     eliu2           Performance issue fixed
---------------------------------------------------------------------------------------
------------------------------TEST SCRIPT----------------------------------------------
--  EXECUTE [dbo].rpt_PercentageOfRevenue '01/01/2017', '01/31/2017', 20
----------------------------------------------------------------------------------------
AS
BEGIN;
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- Build the start and end date variables.
    declare @startdate as datetime;
    declare @endDate as datetime;  

    set @startdate = dbo.udf_GetStandardDateTime(@FromDate);
    set @endDate = dbo.udf_GetStandardDateTime(@ToDate);

    if(datediff(DAY,@startdate,@endDate) <= 45 and datediff(DAY,@startdate,@endDate) >= 0)  
    begin

    set @endDate = dbo.udf_GetStandardDateTime(DATEADD(day, 1, @ToDate));   

    -- Find the first and last TransactionDetailID in this time period.
    declare @startTransactionDetailID int = null;
    declare @endTransactionDetailID int = null;

    declare @void INT
    declare @cancel INT
    SELECT @void=Void,@cancel=Cancel FROM dbo.Enum_TransactionType

    select
        @startTransactionDetailID = MIN(td.TransactionDetailID),
        @endTransactionDetailID = MAX(td.TransactionDetailID)
    from
        dbo.[Transaction] t with (nolock)
        inner loop  join dbo.TransactionHeader th with (nolock) on t.TransactionID = th.TransactionID
        inner loop join dbo.TransactionDetail td with (nolock) on th.TransactionHeaderID = td.TransactionHeaderID
    where
        @startdate <= t.DateCreated and t.DateCreated < @endDate
        OPTION(RECOMPILE)

    SELECT
        ItemID = I.ItemID,
        ItemName = I.ItemName,
        ItemNumber = I.ItemNumber,
        ItemYear = I.ItemYear,
        TransactionDetailTypeID = td.TransactionDetailTypeID,
        TransactionTypeID = td.TransactionTypeID,
        TotalSales = SUM( ISNULL( sa.TotalSaleAmount, 0 ) ),
        POR = CONVERT( DECIMAL(18,2), SUM( ISNULL( sa.TotalSaleAmount, 0 ) ) * @POR / 100 ),
        SoldQuantity = SUM
        (
            CASE
                WHEN td.TransactionTypeID = @void THEN td.Quantity * -1
                WHEN td.TransactionTypeID <>@void THEN td.Quantity
                ELSE 0
            END
        )
        FROM
            dbo.Item i with (nolock)
            left loop join dbo.TransactionDetail td on i.ItemID = td.ItemID 
                           and td.TransactionTypeID <> @cancel
                           and @startTransactionDetailID <= td.TransactionDetailID
                           and td.TransactionDetailID <= @endTransactionDetailID
            left hash join (
                             SELECT  t.TransactionDetailID,                                  
                                     TotalSaleAmount = sum(tdf.Amount)
                              FROM  dbo.TransactionDetail t with (nolock) 
                         LEFT HASH JOIN  dbo.TransactionDetailFee tdf with (nolock) 
                                ON tdf.TransactionDetailID = t.TransactionDetailID  
                                   and tdf.GlobalDistributionID IS NULL
                             WHERE t.TransactionTypeID <> @cancel
                                   and @startTransactionDetailID <= t.TransactionDetailID
                                   and t.TransactionDetailID <= @endTransactionDetailID
                          GROUP BY t.TransactionDetailID
                           ) sa  on sa.TransactionDetailID=td.TransactionDetailID
            
        WHERE 
            -- Only interested in Percentage of revenue items.
            I.IsOCPORItem = 1
            and 
            (
                -- items that were on sale
                (
                    @startdate <= I.SalesEndDate 
                    and @endDate > I.SalesStartDate
                )
                -- or that fell in the date range
                or
                (
                    td.TransactionDetailID is not null
                )
            )
        GROUP BY
            I.ItemID,
            I.ItemName,
            I.ItemNumber,
            I.ItemYear,
            td.TransactionDetailTypeID,
            td.TransactionTypeID
        ORDER BY
            I.ItemYear DESC,
            I.ItemNumber,
            I.ItemName
        OPTION(RECOMPILE)   ;
        end;
END;

GO

PRINT '[INFO] ALTERED PROCEDURE dbo.rpt_PercentageOfRevenue_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO

