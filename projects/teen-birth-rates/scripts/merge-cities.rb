require 'fileutils'
require 'csv'

File.new("edits/02-cities-rates-pop.csv", "w")

result = []

# Read our rates CSV
csv_rates = CSV.read('edits/01-cities-rates.csv', {
		headers: true
	}
)

# Read our rates CSV
csv_pop = CSV.read('raw/population-cities/acs2014_5yr_B01003_16000US1943950.csv', {
		headers: true
	}
)

csv_new = CSV.open('edits/02-cities-rates-pop.csv', 'r+') do |row|
	headers = csv_rates.headers
	headers.push('population')
	
	row << headers

	 csv_rates.each_with_index do |row_rates|
	 	city_rates = "#{row_rates['city']}, IA"

		csv_pop.each do |row_pop|
			city_pop = row_pop['name']
			pop = row_pop['B01003001']
			if city_rates == city_pop
				row_data = row_rates
				row_data.push(pop)

				# Append data to spreadsheet
	  		row << row_data
			end

		end
	end
end

# Re-order columns
CSV.read("edits/02-cities-rates-pop.csv").each do |row|
  result << [row[0], row[9], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]]
end

CSV.open("edits/02-cities-rates-pop.csv", "wb") do |csv|
  result.each{ |row| csv << row }
end