import agate

filename = 'edits/01-ED_Projects_2012-2016.csv'

# Rename columns
column_rename = {
	'Business': 'Business',
	"Minimum Investment": 'Business investment',
	'City Incentives': 'City incentives',
	'Other Community Benefit': 'Community benefit'
}

# The columns we'll include in final spreadsheet
column_select = ('Business','Business investment', 'City incentives', 'Assessment', 'Jobs created', 'Jobs retained', 'Community benefit')

# Edit our spreadsheet
table = agate.Table.from_csv(filename).rename(column_names=column_rename).select(column_select).order_by('City incentives', reverse=True)

# Save edited spreadsheet as new spreadsheet
table.to_csv('output/sorted-ED-projects.csv')