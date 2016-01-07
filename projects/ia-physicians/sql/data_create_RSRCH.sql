CREATE TABLE "topic-03-RSRCH-ia-trim-2013-2014" (
	"Covered_Recipient_Type" VARCHAR(35) NOT NULL, 
	"Teaching_Hospital_ID" INTEGER, 
	"Teaching_Hospital_Name" VARCHAR(37), 
	"Physician_Profile_ID" INTEGER, 
	"Physician_First_Name" VARCHAR(8), 
	"Physician_Middle_Name" VARCHAR(8), 
	"Physician_Last_Name" VARCHAR(12), 
	"Recipient_Primary_Business_Street_Address_Line1" VARCHAR(55) NOT NULL, 
	"Recipient_Primary_Business_Street_Address_Line2" VARCHAR(35), 
	"Recipient_City" VARCHAR(15) NOT NULL, 
	"Recipient_Zip_Code" VARCHAR(10) NOT NULL, 
	"Physician_Primary_Type" VARCHAR(20), 
	"Physician_Specialty" VARCHAR(97), 
	"Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name" VARCHAR(51) NOT NULL, 
	"Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID" BIGINT NOT NULL, 
	"Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name" VARCHAR(59) NOT NULL, 
	"Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State" VARCHAR(4), 
	"Total_Amount_of_Payment_USDollars" FLOAT NOT NULL, 
	"Date_of_Payment" DATE NOT NULL, 
	"Form_of_Payment_or_Transfer_of_Value" VARCHAR(26) NOT NULL, 
	"Record_ID" INTEGER NOT NULL, 
	"Name_of_Associated_Covered_Drug_or_Biological1" VARCHAR(40), 
	"Name_of_Associated_Covered_Drug_or_Biological2" VARCHAR(18), 
	"Name_of_Study" VARCHAR(394), 
	"Research_Information_Link" VARCHAR(79), 
	"Context_of_Research" VARCHAR(474)
);