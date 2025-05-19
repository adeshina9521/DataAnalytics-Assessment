
SELECT * FROM plans_plan;
SELECT * FROM users_customuser;
SELECT * FROM savings_savingsaccount;

-- customer who have saving
WITH CTE AS (SELECT owner_id, 
		sum(is_regular_savings) AS saving_count 
        FROM plans_plan
		WHERE amount > 0  AND is_regular_savings > 0
		GROUP BY owner_id
),

-- customer who has investment

cte1 AS (SELECT owner_id, 
		sum(is_a_fund) AS investment_count 
		FROM plans_plan 
		WHERE amount > 0 AND is_a_fund >= 1
		GROUP BY owner_id),

-- Customer who has both saving and investment
saving_invest_customer AS (SELECT c.owner_id , 
							c.saving_count, 
							c1.investment_count 
                            FROM cte c
							 JOIN   cte1 c1 ON c.owner_id = c1.owner_id),
-- Customer deposite
user_deposite AS (SELECT sc.owner_id,
					sc.saving_count, 
                    sc.investment_count, 
                    sum(ss.confirmed_amount) AS Total_deposits  
					FROM savings_savingsaccount ss
					JOIN saving_invest_customer sc ON ss.owner_id = sc.owner_id
					GROUP BY owner_id
					ORDER BY Total_deposits ASC),

-- Customer detail with full name by concat first name and last name
users AS (SELECT concat(uc.first_name, ' ', uc.last_name) AS full_name,
			ud.owner_id,
            ud.saving_count, 
            ud.investment_count, 
            ud.Total_deposits
		FROM users_customuser uc
		JOIN user_deposite ud ON uc.id= ud.owner_id
		GROUP BY ud.owner_id, full_name)
        
	-- customer total deposite in ascending order
SELECT   owner_id, 
		full_name, 
        saving_count,
        investment_count, 
        total_deposits
        FROM users
		ORDER BY total_deposits ASC


