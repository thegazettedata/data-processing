SELECT Teaching_Hospital_Name,Teaching_Hospital_ID,
SUM( CAST(Total_Amount_of_Payment_USDollars AS REAL) ) AS Total_Amount_of_Payment_USDollars,
SUM(CASE WHEN Category="GNRL" THEN 1 ELSE 0 END) AS General,
SUM(CASE WHEN Category="RSRCH" THEN 1 ELSE 0 END) AS Research
FROM data
WHERE Teaching_Hospital_ID > 0
GROUP BY Teaching_Hospital_ID
ORDER BY Total_Amount_of_Payment_USDollars DESC
LIMIT 50;