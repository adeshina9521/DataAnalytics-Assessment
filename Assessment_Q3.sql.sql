
SELECT * FROM plans_plan;
SELECT * FROM  savings_savingsaccount;

-- active accounts (savings or investments)
WITH ActivePlan AS (SELECT distinct p.owner_id, p.id, p.is_regular_savings, p.is_a_fund,
					CASE WHEN p.is_a_fund =  1 THEN 'INVESTMENT'
						WHEN is_regular_savings =  1 THEN 'SAVING'
						--  ELSE 'Not Active' (to give a null value)
						END AS 'account_type'
					FROM plans_plan p
					JOIN savings_savingsaccount s ON s.owner_id = p.owner_id
					WHERE s.confirmed_amount > 0),
-- LastTransaction date of customer
LastTransaction AS (SELECT distinct plan_id,
					max(date(transaction_date)) as last_transaction_date
					FROM savings_savingsaccount
					WHERE transaction_date >= date_sub(curdate(), interval 365 day)
                    GROUP BY plan_id),
-- RecentTransactions                    
RecentTransaction AS (SELECT distinct plan_id
						FROM savings_savingsaccount
						WHERE transaction_date >= date_sub(curdate(), interval 365 day)
						)
-- active accounts (savings or investments) with no transactions in the last 1 year (365 days) .	
SELECT  DISTINCT ap.id, 
		ap.owner_id,
        ap.account_type,
		lt.last_transaction_date,
        datediff(curdate(), lt.last_transaction_date) AS in_Active_days
        FROM LastTransaction lt
        JOIN ActivePlan ap
        ON ap.id = lt.plan_id
        WHERE ap.account_type IS NOT NULL
        GROUP BY ap.id, ap.owner_id, ap.account_type