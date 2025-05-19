
SELECT * FROM plans_plan;
SELECT * FROM savings_savingsaccount;

-- Number of Transaction per customer
WITH TransactionCounts AS( SELECT owner_id,
		count(id) AS cutomer_count
		FROM savings_savingsaccount
        GROUP BY owner_id),
        
-- Number of Months in the analysis period
PeriodMonths AS (SELECT timestampdiff(month, min(transaction_date), max(transaction_date)) + 1  AS num_months
		FROM savings_savingsaccount),

-- Aaverage Transaction per month
CustomerAverage AS (SELECT t.owner_id,
		t.cutomer_count,
        t.cutomer_count * 1.0 / p.num_months AS  avg_transactions_per_month
        FROM TransactionCounts t
        CROSS JOIN PeriodMonths p)
-- Customer count into segment i.e High frequency, medium frequency and low frequency
SELECT CASE
			WHEN avg_transactions_per_month >= 10  THEN 'High Frequency'
            WHEN avg_transactions_per_month <= 2  THEN 'Low Frequency'
            ELSE 'Medium Frequency'
            END AS frequency_category,
		cutomer_count,
        avg_transactions_per_month
        FROM CustomerAverage
        ORDER BY avg_transactions_per_month DESC




