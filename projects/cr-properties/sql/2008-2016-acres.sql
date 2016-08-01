SELECT '2008' as 'year', sum(Acres) as 'acres'
FROM data2008
UNION
SELECT '2009', sum(Acres)
FROM data2009
UNION
SELECT '2010', sum(Acres)
FROM data2010
UNION
SELECT '2011', sum(Acres)
FROM data2011
UNION
SELECT '2012', sum(Acres)
FROM data2012
UNION
SELECT '2013', sum(Acres)
FROM data2013
UNION
SELECT '2014', sum(Acres)
FROM data2014
UNION
SELECT '2015', sum(Acres)
FROM data2015
UNION
SELECT '2016', sum(Acres)
FROM data2016;