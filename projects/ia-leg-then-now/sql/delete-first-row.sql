Delete from datanowhouse where rowid IN (Select rowid from datanowhouse limit 1);
