SELECT data2016.GIS_Number, data2016."Map Name", data2016.Class, data2016.Doing_Business_As, data2016.Address, data2016.Deedholder, data2016.Acres, data2016."Residential Occupancy Type", data2016."Style Descr", data2016."Year Built", data2016."Total Living Area", data2016."Commercial Occupancy Type", data2016."Year Built_2", data2016."Gross Bldg Area", data2008."2008 Total", data2016."2016 Total"
FROM data2008
INNER JOIN data2016
ON data2008.GIS_Number=data2016.GIS_Number

LIMIT 1000000000000000000 OFFSET 1;