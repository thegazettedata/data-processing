SELECT "Service Name",
COUNT(time_diff_edit) as calls,
COUNT(case when (time_diff_edit < 7) then 1 else null end) as calls_under_7,
ROUND( COUNT(case when (time_diff_edit < 7) then 1 else null end) * 1.0 / COUNT(time_diff_edit) * 100, 2) as percent,
ROUND(avg(time_diff_edit), 2) as avg
FROM data
WHERE Year > 2009 AND "Fire Incident Type - Code" = 111
GROUP BY "Service Name"
ORDER BY calls DESC