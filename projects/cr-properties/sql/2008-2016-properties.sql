SELECT '2008' as 'year', count(Acres) - 1 as 'properties'
FROM data2008
UNION
SELECT '2009', count(Acres) - 1
FROM data2009
UNION
SELECT '2010', count(Acres) - 1
FROM data2010
UNION
SELECT '2011', count(Acres) - 1
FROM data2011
UNION
SELECT '2012', count(Acres) - 1
FROM data2012
UNION
SELECT '2013', count(Acres) - 1
FROM data2013
UNION
SELECT '2014', count(Acres) - 1
FROM data2014
UNION
SELECT '2015', count(Acres) - 1
FROM data2015
UNION
SELECT '2016', count(Acres) - 1
FROM data2016;