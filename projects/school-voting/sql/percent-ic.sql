SELECT COUNT(case when (FirstName > "" AND FIRST_NAME > "" AND SCHOOL_ELECTION_091013 > "") then 1 else null end) AS voters,
COUNT(case when (FirstName > "") then 1 else null end) AS employees, ROUND(COUNT(case when (FirstName > "" AND FIRST_NAME > "" AND SCHOOL_ELECTION_091013 > "") then 1 else null end) * 100.0 / COUNT(case when (FirstName > "") then 1 else null end), 2) as percent
from data;