SELECT Physician_Primary_Type,
SUM( CAST(Total_Amount_of_Payment_USDollars AS REAL) ) AS Total_Amount_of_Payment_USDollars,
SUM(CASE WHEN Category="GNRL" THEN 1 ELSE 0 END) AS General,
SUM(CASE WHEN Category="RSRCH" THEN 1 ELSE 0 END) AS Research
FROM data
WHERE Physician_Primary_Type > 0
GROUP BY Physician_Primary_Type
ORDER BY Total_Amount_of_Payment_USDollars DESC
LIMIT 50;