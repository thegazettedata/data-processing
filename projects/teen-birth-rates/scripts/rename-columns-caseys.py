import agate

# For our spreadsheet
column_rename = {
	"Casey's Location": 'city',
	'County': 'county',
	'County # (See Map)': 'county_num',
	'Walmart in town?': 'walmart',
	'Title X Agency & Clinic (Nearby ?)': 'title_x',
	'Title X Satellite Clinic': 'title_y',
	'Satellite Clinic with Referral for Physical Examination': 'referral'
}

filename = 'edits/03-caseys-geo.csv'

table = agate.Table.from_csv(filename).rename(column_names=column_rename)
	
table.to_csv('edits/04-caseys-rename-geo.csv')