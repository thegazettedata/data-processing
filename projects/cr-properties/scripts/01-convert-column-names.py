import agate

# For our parcels spreadsheets
column_renames_parcels = {
	'GIS Number': 'GIS_Number',
	'GIS Number_2': 'GIS_Number_2'
}

for year in range(2008, 2017):
	filename = 'raw/csv/' + str(year) + '-parcels.csv'
	print filename

	table = agate.Table.from_csv(filename).rename(column_names=column_renames_parcels)
	
	table.to_csv('edits/01-' + str(year) + '-parcels-rename.csv')


# For our valuations spreadsheets
column_renames_valuations = {
	'GISNUM': 'GIS_Number_valuations',
	'GIS_Number': 'GIS_Number_valuations',
	'Map Name': 'Map_Name_valuations',
	'Class': 'Class_valuations'
}

for year in range(2008, 2017):
	filename = 'raw/csv/' + str(year) + '-valuations.csv'
	print filename

	table = agate.Table.from_csv(filename).rename(column_names=column_renames_valuations)
	
	table.to_csv('edits/01-' + str(year) + '-valuations-rename.csv')