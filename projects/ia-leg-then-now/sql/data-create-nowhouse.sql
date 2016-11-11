CREATE TABLE datanowhouse (
	"District" VARCHAR(20) NOT NULL, 
	"Name" VARCHAR(25) NOT NULL, 
	"DOB" VARCHAR(10) NOT NULL, 
	"Start date" DATE NOT NULL, 
	"Age" INTEGER NOT NULL, 
	"Party" VARCHAR(1) NOT NULL, 
	"Gender" VARCHAR(1) NOT NULL, 
	"Minority" BOOLEAN NOT NULL, 
	"House terms" INTEGER NOT NULL, 
	"Senate terms" INTEGER NOT NULL, 
	"Total terms" INTEGER NOT NULL, 
	"Occupation" VARCHAR(29) NOT NULL, 
	"Education" VARCHAR(15), 
	"Children" INTEGER NOT NULL, 
	"Grandchildren" INTEGER, 
	"Birth state" VARCHAR(4), 
	precincts VARCHAR(27)
);
