SELECT '2008' as 'year', sum("2008 Total") as 'value (in dollars)'
FROM data2008
UNION
SELECT '2009', sum("2009 Total")
FROM data2009
UNION
SELECT '2010', sum("2010 Total")
FROM data2010
UNION
SELECT '2011', sum("2011 Total")
FROM data2011
UNION
SELECT '2012', sum("2012 Total")
FROM data2012
UNION
SELECT '2013', sum("2013 Total")
FROM data2013
UNION
SELECT '2014', sum("2014 Total")
FROM data2014
UNION
SELECT '2015', sum("2015 Total")
FROM data2015
UNION
SELECT '2016', sum("2016 Total")
FROM data2016;