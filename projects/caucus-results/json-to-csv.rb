# Convert our JSON data into CSV
require 'json'
require "csv"

# Grab arguments
ARGV.each_with_index do |argument, num|
	# Whether or not we are working
	# With county or statewide data
	if num == 0
		$data = JSON.parse( File.read("#{argument}") )
	# Our CSV file
	elsif num == 1
		$csv = argument
	end
end

# Detects if we're appended the header row in our CSV file
header_appended = false

# Create empty array and append CSV header values
# These will include candidate names
header_row = [$api_type]

if $api_type == 'county'
	$api_initial = 'CountyResults'
elsif $api_type == 'statewide'
	$api_initial = 'StateResults'
end

# Loop through each result
# And append header row
$data[$api_initial].each_with_index do |result, num_result|
	if $api_type == 'county'
		candidates_obj = result['Candidates']
	elsif $api_type == 'statewide'
		candidates_obj = result
	end

	# Loop through each candidate
	if candidates_obj.length > 0

		# Append header row to CSV
		if !header_appended
			
			# Append candidate names to empty array
			# That will become our header row
			if $api_type == 'county'
				candidates_obj.each_with_index do |candidates, num_candidates|
					header_row << candidates['Candidate']['DisplayName']
				end
			elsif $api_type == 'statewide'
				header_row << candidates_obj['Candidate']['DisplayName']
			end

			if $api_type == 'county'
				# Final column indicates if there is a winner in the results
				header_row << 'winner'

				# Append data to CSV
				CSV.open($csv, "a+") do |csv|
  				csv << header_row
				end
			end

		end

		if $api_type == 'county'
			header_appended = true
		end
	end
end

if $api_type == 'statewide'
	header_row << 'winner'

	CSV.open($csv, "a+") do |csv|
		csv << header_row
	end
end

# With the header created, we will now append actual data
# $data['CountyResults'].each_with_index do |county, num_county|
# 	county_name = county['County']['Name']
# end

