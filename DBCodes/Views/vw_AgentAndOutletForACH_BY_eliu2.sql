SET NOCOUNT ON


IF OBJECT_ID ('[dbo].[vw_AgentAndOutletForACH_BY_eliu2]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [dbo].[vw_AgentAndOutletForACH_BY_eliu2]	
END
GO

CREATE VIEW [dbo].[vw_AgentAndOutletForACH_BY_eliu2]
AS
/* Purpose: Returns all the Agent and Agent Journals that are subject to ACH */
/* Get All Journals */
SELECT  [JournalID] = J.[JournalID],
        [OutletID] = ISNULL( O.[OutletID], 0 ),
        [AgentID] = O.[AgentID],
        [AgentBankAccountID] = ABA.[AgentBankAccountID],
        [OutstandingAmount] = J.[OutstandingAmount]
    FROM [dbo].[Outlet] O
		cross join dbo.Enum_AgentBankAccountStatus eabas
		cross join dbo.Enum_StatusCode_Journal escj
        INNER JOIN [dbo].[Journal] J ON O.[OutletID] = J.[OutletID]
		INNER JOIN [dbo].[Statement] S ON J.[OutletID] = S.[OutletID]
		INNER JOIN [dbo].[JournalStatement] JS ON J.[JournalID] = JS.[JournalID] AND S.[StatementID] = JS.[StatementID]
        INNER JOIN [dbo].[Agent] A ON O.[AgentID] = A.[AgentID]
		INNER JOIN [dbo].[AgentBankAccount] ABA ON A.[AgentID] = ABA.[AgentID]
		INNER JOIN [dbo].[OutletPaymentMethod] OPM ON ABA.[AgentBankAccountID] = OPM.[AgentBankAccountID]
    WHERE [dbo].[udf_IsOutletACHDate]( O.[OutletID], [dbo].[udf_GetCurrentDateTime]() ) = 1
        AND O.[IsACHAllowed] = 1
        AND A.[IsACHAllowed] = 1
        -- TODO - Buck, does this actually do anything? We inner joined from Outlet to Journal to Statement on OutletID. Seems worthless to me.
        AND S.[StatementID] in (SELECT  innerS.[StatementID] FROM [dbo].[Statement] innerS WHERE O.[OutletID] = innerS.[OutletID])
        AND J.[StatusCodeID] = escj.[Open]
        AND ABA.[StatusCodeID] = eabas.ACTIVE
        AND OPM.[OutletPaymentMethodID] = (SELECT MAX( OPM.[OutletPaymentMethodID] )
                                             FROM [dbo].[OutletPaymentMethod] OPM
                                            WHERE O.[OutletID] = OPM.[OutletID] AND OPM.[EffectiveDate] <= [dbo].[udf_GetCurrentDateTime]()
                                          )
        AND J.[ACHBatchDetailID] IS NULL
        AND ISNULL( J.[IsInDispute], 0 ) = 0
UNION
/* Get Agents Only */
SELECT [JournalID],[OutletID],[AgentID],[AgentBankAccountID],[OutstandingAmount]
FROM(
SELECT  [JournalID] = J.[JournalID],
        [OutletID] = 0,
        [AgentID] = A.[AgentID],
        [AgentBankAccountID] = ABA.[AgentBankAccountID],
        [OutstandingAmount] = J.[OutstandingAmount],
		[IsACHDate] = [dbo].[udf_IsAgentOutletACHDate_BY_eliu2]( J.[AgentID], [dbo].[udf_GetCurrentDateTime]() ) 
    FROM [dbo].[Agent] A
		cross join dbo.Enum_AgentBankAccountStatus eabas
		cross join dbo.Enum_StatusCode_Journal escj
        INNER JOIN [dbo].[Journal] J ON A.[AgentID] = J.[AgentID]
		INNER JOIN [dbo].[AgentBankAccount] ABA ON J.[AgentID] = ABA.[AgentID]
		INNER JOIN [dbo].[Statement] S ON J.[AgentID] = S.[AgentID] AND S.OutletID IS NULL
		INNER JOIN [dbo].[JournalStatement] JS ON J.[JournalID] = JS.[JournalID] AND S.[StatementID] = JS.[StatementID]
    WHERE
		A.IsACHAllowed = 1 -- Need to respect the ach allowed bit
        AND ABA.[IsPrimaryAccount] = 1
        AND ABA.[StatusCodeID] = eabas.ACTIVE
        AND ISNULL( J.[OutletID], 0 ) = 0
        AND J.[StatusCodeID] = escj.[Open]
        AND J.[ACHBatchDetailID] IS NULL
        AND ISNULL( J.[IsInDispute], 0 ) = 0
) o WHERE o.[IsACHDate]= 1
UNION
/* Get any credits that are not tied to a statement */
SELECT [JournalID],[OutletID],[AgentID],[AgentBankAccountID],[OutstandingAmount]
FROM(
SELECT  [JournalID] = J.[JournalID],
        [OutletID] = ISNULL( J.[OutletID], 0 ),
        [AgentID] = J.[AgentID],
        [AgentBankAccountID] = CASE WHEN J.[OutletID] IS NULL THEN (
																	SELECT  [AgentBankAccountID] = ABA.[AgentBankAccountID]
																	  FROM [dbo].[AgentBankAccount] ABA
																CROSS JOIN dbo.Enum_AgentBankAccountStatus eabas
																	 WHERE J.[AgentID] = ABA.[AgentID]
																		   AND ABA.[IsPrimaryAccount] = 1
																		   AND ABA.[StatusCodeID] = eabas.ACTIVE
																   )
									ELSE (SELECT  [AgentBankAccountID] = OPM.[AgentBankAccountID]
											FROM [dbo].[OutletPaymentMethod] OPM
									  CROSS JOIN dbo.Enum_AgentBankAccountStatus eabas
									  INNER JOIN [dbo].[AgentBankAccount] ABA ON OPM.[AgentBankAccountID] = ABA.[AgentBankAccountID]
										   WHERE ABA.[StatusCodeID] = eabas.ACTIVE
												 AND OPM.[OutletPaymentMethodID] = (SELECT MAX( OPM2.[OutletPaymentMethodID] )
																					  FROM [dbo].[OutletPaymentMethod] OPM2
																					 WHERE J.[OutletID] = OPM2.[OutletID]
																						   AND OPM2.[EffectiveDate] <= [dbo].[udf_GetCurrentDateTime]()
																					  )
										 )
							   END,
        [OutstandingAmount] = J.[OutstandingAmount],
		[IsACHDate] = [dbo].[udf_IsAgentOutletACHDate_BY_eliu2]( J.[AgentID], [dbo].[udf_GetCurrentDateTime]()) 
    FROM dbo.[Journal] J
		cross join dbo.Enum_StatusCode_Journal escj
		inner join Agent A on J.AgentID = A.AgentID
		left join Outlet O on J.OutletID = O.OutletID
    WHERE
		A.IsACHAllowed = 1 -- Agent is always present.
		AND (O.IsACHAllowed is null or O.IsACHAllowed = 1) -- Either the Journal isn't attached to an Outlet OR the Outlet still permits ACH
		AND NOT EXISTS ( SELECT * FROM [dbo].[JournalStatement] JS WHERE J.[JournalID] = JS.[JournalID] )
        AND J.[OutstandingAmount] < 0
        AND J.[StatusCodeID] = escj.[Open]
        AND J.[ACHBatchDetailID] IS NULL
        AND ISNULL( J.[IsInDispute], 0 ) = 0
) o WHERE o.[IsACHDate]= 1

GO

IF OBJECT_ID ('[dbo].[vw_AgentAndOutletForACH_BY_eliu2]', 'V') IS NOT NULL
    PRINT '[INFO] ALTERED VIEW dbo.vw_AgentAndOutletForACH_BY_eliu2 - ' + CONVERT(VARCHAR(255), SYSDATETIME(), 121)
GO

SET NOCOUNT OFF