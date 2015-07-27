SELECT Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State,Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID,
SUM( CAST(Total_Amount_of_Payment_USDollars AS REAL) ) AS Total_Amount_of_Payment_USDollars,
SUM(CASE WHEN Category="GNRL" THEN 1 ELSE 0 END) AS General,
SUM(CASE WHEN Category="RSRCH" THEN 1 ELSE 0 END) AS Research
FROM data
WHERE Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID > 0
GROUP BY Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID
ORDER BY Total_Amount_of_Payment_USDollars DESC
LIMIT 50;