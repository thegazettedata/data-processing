SELECT Year,
COUNT(Year) AS "Count",
SUM("Minimum Investment") AS "Minimum Investment",
SUM("City Incentives") as "City Incentives",
SUM("Assessment") as "Assessment",
SUM("Jobs created") as "Jobs created",
SUM("Jobs retained") as "Jobs retained"
FROM data
GROUP BY Year
ORDER BY SUM("Minimum Investment") DESC;