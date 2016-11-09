require 'csv'

# We'll put the header names here
@headers = ['county', 'population']

# Read our original CSV
csv_og = CSV.read('edits/01-counties-rates.csv', {
		headers: true,
		return_headers: false
	}
)

# Read our population CSV
csv_pop = CSV.read('raw/population-counties/acs2014_5yr_B01003_05000US19049.csv', {
		headers: true
	}
)

# Keeps track of the first county in the data
# We need just the first one to create the headers
first_county = true

# Keeps track of what row we are creating
# As we re-arrange the data
# Ultimately, we'll have a row for each county
row_count = 0

# Create the header row
csv_og.each do |row|
	# This is set to false after we're done with the first county
	if row[0] == nil
		first_county = false
	end

	# If we're on the first county, use the data to create the headers
	if first_county && row[0].to_i != 0
		@headers.push(row[0])
	end
end

# Write formatted to a new CSV
csv_new = CSV.open('edits/02-counties-rates-pop.csv', 'wb',
	write_headers: true,
	headers: @headers
) do |csv|
	# We'll append each county's name and data for each here
	county_name = ''
	population = 0
	yearly_data = []

	# Pull out data for each data for each year
	csv_og.each do |row|
		if row[1] != nil
			yearly_data.push(row[1])
		end

		# This indicates we're run across a county name in the first row
		if row[0].to_i == 0 && row[0] != nil
			county_name = row[0]

			yearly_data = []
			row_count += 1
		end

		# Add in population by matching county names
		csv_pop.each do |row|
			county_name_ext = "#{county_name} County, IA"
			# p row

			if county_name_ext == row['name']
				population = row[2]
			end
		end

		# After we're ran through a county and collected the data
		# And the data for that county is collected,
		# We'll append the data to the CSV file
		if row[0] == nil
			# Final data for this county
			final_data = [county_name, population, yearly_data[0], yearly_data[1], yearly_data[2], yearly_data[3], yearly_data[4], yearly_data[5], yearly_data[6], yearly_data[7], yearly_data[8]]

			csv << final_data
		end
	end
end