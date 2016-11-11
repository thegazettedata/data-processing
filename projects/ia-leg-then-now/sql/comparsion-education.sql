SELECT datanowhouse.Education, datanowsenate.Education, datathenhouse.Occupation, datathensenate.Occupation
FROM datanowhouse
INNER JOIN datanowsenates
ON datanowhouse.District=datanowsenate.District

LIMIT 1000000000000000000 OFFSET 1;