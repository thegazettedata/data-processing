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
	headers.push('population','county')
	
	row << headers

	 csv_rates.each_with_index do |row_rates|
	 	city_rates = "#{row_rates['city']}, IA"

		csv_pop.each do |row_pop|
			city_pop = row_pop['name']
			pop = row_pop['B01003001']
			if city_rates == city_pop
				row_data = row_rates
				row_data.push(pop)

				# Get county of city from text file
				text_file = File.open('raw/IowaCitiesandCounties.txt').read
				text_file.gsub!(/\r\n?/, "\n")

				text_file.each_line do |line|
					new_city_rates = city_rates.split(', IA').first
					
					city_county = "#{line}".split(' city')
  				city = city_county.first
  				county = city_county[1]
  				
  				if !county.nil?
  					county = county.split(" ( ")[1].split(" County )\n").first
  				end

  				# Match city in city, county text file
  				# With city currently looping through
  				if city == new_city_rates
  					row_data.push(county)

  					# Append data to spreadsheet
	  				row << row_data
  				end
				end
			end

		end
	end
end

# Re-order columns
CSV.read("edits/02-cities-rates-pop.csv").each do |row|
  result << [row[0], row[4], row[5], row[1], row[2], row[3]]
end

CSV.open("edits/02-cities-rates-pop.csv", "wb") do |csv|
  result.each{ |row| csv << row }
end