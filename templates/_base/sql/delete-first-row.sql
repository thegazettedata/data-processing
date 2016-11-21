Delete from data where rowid IN (Select rowid from data limit 1);
