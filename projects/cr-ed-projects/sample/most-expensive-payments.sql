SELECT *
FROM data
ORDER BY CAST(Total_Amount_of_Payment_USDollars AS REAL) desc
LIMIT 25;