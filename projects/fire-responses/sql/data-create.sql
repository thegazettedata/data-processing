CREATE TABLE "01-response-times-trim" (
	"Service Name" VARCHAR(32) NOT NULL, 
	time_diff_edit INTEGER, 
	"Incident Date" DATE NOT NULL, 
	"Year" INTEGER NOT NULL, 
	"Full Address" VARCHAR(57) NOT NULL, 
	"Incident City" VARCHAR(26) NOT NULL, 
	"Fire Incident Type" VARCHAR(50) NOT NULL, 
	"Fire Incident Type - Code" INTEGER NOT NULL, 
	lat VARCHAR(10) NOT NULL, 
	long FLOAT
);
