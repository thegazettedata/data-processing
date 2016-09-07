SELECT Physician_First_Name,Physician_Middle_Name,Physician_Last_Name,Recipient_Primary_Business_Street_Address_Line1,Recipient_Primary_Business_Street_Address_Line2,Recipient_City,Recipient_Zip_Code,Physician_Primary_Type,Physician_Specialty,Physician_Profile_ID,Category,
SUM( CAST(Total_Amount_of_Payment_USDollars AS REAL) ) AS Total_Amount_of_Payment_USDollars,
SUM(CASE WHEN Category="GNRL" THEN 1 ELSE 0 END) AS General,
SUM(CASE WHEN Category="RSRCH" THEN 1 ELSE 0 END) AS Research
FROM data
WHERE Physician_Profile_ID > 0
GROUP BY Physician_Profile_ID
ORDER BY Total_Amount_of_Payment_USDollars DESC
LIMIT 100;