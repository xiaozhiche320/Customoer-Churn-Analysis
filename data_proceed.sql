--  Check for duplicates --
SELECT `Customer ID`, COUNT(`Customer ID`) cnt FROM customer_churn
GROUP BY `Customer ID`
HAVING cnt>1;


-- 1. Find total number of customers --
SELECT COUNT(`Customer ID`)
FROM customer_churn;
-- result: 7043

-- 2. figure: How many customers churn/stay/join last quarter and what is churn rate
SELECT 
	SUM(IF(`Customer Status`='Churned',1,0)) AS churned_num,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0))/(SELECT COUNT('Customer_ID') FROM customer_churn),2) AS Churn_Rate,
    SUM(IF(`Customer Status`='Stayed',1,0)) AS stayed_num,
    ROUND(SUM(IF(`Customer Status`='Stayed',1,0)) /(SELECT COUNT('Customer_ID') FROM customer_churn),2) AS Stayed_Rate,
    SUM(IF(`Customer Status`='Joined',1,0)) AS joined_num,
    ROUND(SUM(IF(`Customer Status`='Joined',1,0))/(SELECT COUNT('Customer_ID') FROM customer_churn),2) AS Joined_Rate
FROM customer_churn;


-- 3. Our loss for churn customer -- churn revenue
SELECT 
    `Customer Status`,
    COUNT(`Customer ID`) AS customer_count,
    SUM(`Total Revenue`) AS Churned_Revenue,
    ROUND(SUM(`Total Revenue`) * 100 / SUM(SUM(`Total Revenue`)) OVER(), 1) AS Revenue_Percentage
FROM customer_churn
GROUP BY `Customer Status`
ORDER BY `Customer Status`;


-- 17.2% loss in entire revenue


-- 3. Customer Gender and Age Analysis --
SELECT 
    Gender,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned',1,0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0))/COUNT(`Customer ID`),2) AS Churn_Rate
FROM customer_churn
GROUP BY Gender;

-- almost same, not significant affect

SELECT 
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 50 THEN '35-50'
        WHEN Age BETWEEN 51 AND 64 THEN '51-64'
        ELSE '65+'
    END AS Age_Group,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned',1,0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0))/COUNT(`Customer ID`),2) AS Churn_Rate
FROM customer_churn
GROUP BY Age_Group
ORDER BY Age_Group;

-- when it comes to 65+ there is a high churn rate

-- Is it related to marital status? seems yes
SELECT 
    Married,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned',1,0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0))/COUNT(`Customer ID`),2) AS Churn_Rate
FROM customer_churn
WHERE Married IN ('Yes', 'No')
GROUP BY Married;




-- 查询不同抚养情况下客户的流失情况
SELECT 
    CASE 
        WHEN `Number of Dependents` = 0 THEN 'No Dependents'
        WHEN `Number of Dependents` = 1 THEN '1 Dependent'
        WHEN `Number of Dependents` = 2 THEN '2 Dependents'
        ELSE '3+ Dependents'
    END AS `Dependents_Group`,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned',1,0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0))/COUNT(`Customer ID`),2) AS Churn_Rate
FROM customer_churn
GROUP BY `Dependents_Group`;

-- customer with not dependents take the highest rates

-- city

SELECT City, COUNT(`Customer ID`) AS num ,ROUND(SUM(IF(`Customer Status`='Churned',1,0))/COUNT(`Customer ID`),2) AS churn_rate
FROM customer_churn
GROUP BY City 
HAVING COUNT(`Customer ID`)>30
ORDER BY churn_rate DESC
LIMIT 5;



-- statics the tenure, most people choose to leave in first 6 month
SELECT 
    CASE 
        WHEN `Tenure in Months` >= 0 AND `Tenure in Months` <= 6 THEN '0-6 Months'
        WHEN `Tenure in Months` > 6 AND `Tenure in Months` <= 12 THEN '6-12 Months'
        WHEN `Tenure in Months` > 12 AND `Tenure in Months` <= 24 THEN '12-24 Months'
        ELSE '24+ Months'
    END AS Tenure_Group,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned',1,0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0)) / COUNT(`Customer ID`), 2) AS Churn_Rate
FROM customer_churn
GROUP BY Tenure_Group;

-- is it relevant to offer?
SELECT 
    Offer,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(CASE WHEN `Customer Status` = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(CASE WHEN `Customer Status` = 'Churned' THEN 1 ELSE 0 END) * 100 / COUNT(`Customer ID`), 2) AS Churn_Rate
FROM customer_churn
GROUP BY Offer
ORDER BY Churn_Rate DESC;


-- churn reasons --competitor take most 
SELECT 
    `Churn Reason`,
    COUNT(`Customer ID`) AS Churned_Customers
FROM customer_churn
WHERE `Customer Status` = 'Churned'
GROUP BY `Churn Reason`
ORDER BY Churned_Customers DESC;


-- churn service type only use phone will keep more internet bad
SELECT 
    `Phone Service`,
    `Internet Service`,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned',1,0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned',1,0)) / COUNT(`Customer ID`), 2) AS Churn_Rate
FROM customer_churn
GROUP BY `Phone Service`, `Internet Service`
ORDER BY Churn_Rate DESC;

--  what internet type did 'compititor' churners have? 
SELECT 
	`Internet Type`,
	COUNT(`Customer ID`) AS churned,
	ROUND(COUNT(`Customer ID`)*100 / SUM(COUNT(`Customer ID`)) over(),1) AS churn_percentage 
FROM customer_churn
WHERE `Customer Status` = 'Churned' AND `Churn Category` = 'Competitor'
GROUP BY `Internet Type`, `Churn Category`
ORDER BY churn_percentage DESC;


-- contract type 
SELECT 
    `Contract`,
    COUNT(`Customer ID`) AS Total_Customers,
    SUM(IF(`Customer Status`='Churned', 1, 0)) AS Churned_Customers,
    ROUND(SUM(IF(`Customer Status`='Churned', 1, 0)) / COUNT(`Customer ID`), 2) AS Churn_Rate
FROM customer_churn
GROUP BY `Contract`
ORDER BY Churn_Rate DESC;
