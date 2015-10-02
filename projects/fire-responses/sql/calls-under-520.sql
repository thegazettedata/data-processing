SELECT "City",
COUNT("Responsetime") as calls,
COUNT(case when ("Responsetime" < 5.21) then 1 else null end) as calls_under_521,
ROUND(avg("Responsetime"), 2) as avg,
ROUND( COUNT(case when ("Responsetime" < 5.21) then 1 else null end) * 1.0 / COUNT("Responsetime") * 100, 1) as percent
FROM data
WHERE "City" > 0
GROUP BY "City"
ORDER BY calls DESC