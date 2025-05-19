
SELECT * from users_customuser;
select *  from savings_savingsaccount;

-- tenure month, total transation 
WITH cte AS (SELECT  uc.id, 
     concat(uc.first_name, ' ', uc.last_name) AS fullname, -- full name
	timestampdiff(month, ss.transaction_date, curdate() ) as tenure_month, -- tenure month
    count(ss.id) as total_transaction, -- total transaction
    CASE 
		WHEN timestampdiff(month, ss.transaction_date, curdate() ) = 0 THEN 0
        ELSE (count(ss.owner_id) * 1.0 / timestampdiff(month, ss.transaction_date, curdate() ))
				* 12
                * avg(ss.amount * 0.001)
		END AS estimated_clv -- calculate the estimated CLV
    FROM savings_savingsaccount ss
    JOIN users_customuser uc 
	ON uc.id = ss.owner_id 
    WHERE ss.amount > 0
    GROUP BY  uc.id, concat(uc.first_name, ' ', uc.last_name), ss.transaction_date
    ORDER BY estimated_clv DESC)
    
    SELECT id, 
			fullname,
            tenure_month, 
            sum(total_transaction) AS total_transaction, -- Total transaction 
            sum(estimated_clv) AS estimated_clv -- total estimated clv
            FROM cte
		GROUP BY id, fullname, tenure_month
		ORDER BY estimated_clv DESC -- Arranged estimated clv in descinding day