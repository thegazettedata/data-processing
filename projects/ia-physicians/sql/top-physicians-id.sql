SELECT Physician_Profile_ID
FROM data
WHERE Physician_Profile_ID > 0
GROUP BY Physician_Profile_ID
ORDER BY SUM( CAST(Total_Amount_of_Payment_USDollars AS REAL) ) DESC
LIMIT 100;