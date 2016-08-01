SELECT GIS_Number, "Map Name", Class, Doing_Business_As, Address, Deedholder, Acres, "Residential Occupancy Type", "Style Descr", "Year Built", "Total Living Area", "Commercial Occupancy Type", "Year Built_2",  "2013 Total", "2008 Total"
FROM data2013
WHERE GIS_Number NOT IN (SELECT GIS_Number FROM data2008)
ORDER BY "2003 Total" ASC;