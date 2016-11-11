CREATE TABLE datanowsenate (
	"District" VARCHAR(22) NOT NULL, 
	"Name" VARCHAR(19) NOT NULL, 
	"DOB" VARCHAR(10) NOT NULL, 
	"Start date" DATE NOT NULL, 
	"Age" INTEGER NOT NULL, 
	"Party" VARCHAR(1) NOT NULL, 
	"Gender" VARCHAR(1) NOT NULL, 
	"Minority" BOOLEAN NOT NULL, 
	"House terms" INTEGER NOT NULL, 
	"Senate terms" INTEGER NOT NULL, 
	"Total terms" INTEGER NOT NULL, 
	"Occupation" VARCHAR(21) NOT NULL, 
	"Education" VARCHAR(16) NOT NULL, 
	"Children" INTEGER NOT NULL, 
	"Grandchildren" INTEGER NOT NULL, 
	"Birth state" VARCHAR(2) NOT NULL, 
	precincts VARCHAR(27)
);
