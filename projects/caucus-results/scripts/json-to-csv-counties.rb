# Convert our JSON data into CSV
require 'json'
require "csv"

# Grab arguments
ARGV.each_with_index do |argument, num|
	# Our JSON file
	if num == 0
		$data = JSON.parse( File.read("#{argument}") )
	# Our CSV file
	elsif num == 1
		$csv = argument
	elsif num == 2
		$party = argument
	end
end

# Detects if we're appended the header row in our CSV file
header_appended = false

# Create empty array and append CSV header values
# These will include candidate names
header_row = ['counties']
candidates_array = []

# Sort counties alphabetically
data_alphabetical = $data['CountyResults'].sort! { |a,b| a['County']['Name'].downcase <=> b['County']['Name'].downcase }

# Loop through each result
# And append header row
data_alphabetical.each_with_index do |result, num_result|
	candidates_obj = result['Candidates']

	# Loop through each candidate
	if candidates_obj.length > 0

		# Append header row to CSV
		if !header_appended
			
			# Append candidate names to empty array
			# That will become our header row
			candidates_obj.each_with_index do |candidates, num_candidates|
				candidates_array << candidates['Candidate']['LastName']
			end

			# Alphabetize candidates
			candidates_array = candidates_array.sort_by{|word| word.downcase}

			# Append candidates to header row array
			(header_row << candidates_array).flatten!
			
			# Final column indicates if there is a winner in the results
			header_row << 'winner'
			header_row << 'precincts reporting'
			header_row << 'precincts total'

			# Append header row
			CSV.open($csv, "a+") do |csv|
				csv << header_row
			end

		end

		header_appended = true
	end
end

# With the header created, we will now append actual data
$data['CountyResults'].each_with_index do |county, num_county|
	# Create empty array for each rows' data
	# First column will be county name
	county_name = county['County']['Name']
	ind_row = [county_name]
	# Candidates object
	candidates_obj = county['Candidates']
	# Number of candidates
	num_of_candidates = candidates_array.length
	# Number of results
	num_of_results = candidates_obj.length

	if county_name != 'Military' && county_name != 'DEMO' && county_name != 'Caucus Expansion Results'
		# Enter default values for each county
		# Which will be zero percent for each candidate
		# And a false value for winner column
		for i in 1..num_of_candidates
			ind_row << 0
		end

		ind_row << ''

		# If we have candidate result data
		# We'll add it to the empty array for this row
		if num_of_results > 0
			candidates_obj.each_with_index do |candidate, num_candidate|
				# Result for this canidate
				# It may be blank
				if $party == 'iagop'
					# Percentage of the vote for this candidate
					result = candidate['Result']
				else
					# Percentage of the vote for this candidate
					result = candidate['WinPercentage']
				end
				
				is_winner = candidate['IsWinner']

				# Candidate name
				name = candidate['Candidate']['LastName']
				# Detects the column number in the CSV
				# For this particular candidate
				candidate_index = header_row.index(name)

				# If blank, let's make zero
				if result.nil?
					result = 0
				end

				# Format the result to percentages
				# And append to CSV
				if $party == 'iagop'
					result_format = result
				else
					result_format = (result * 100).round(1)
				end

				ind_row[candidate_index] = result_format

				if is_winner
					ind_row[ind_row.length - 1] = name
				end
			end
		end

		# Append precincts
		precincts_reporting = county['PrecinctsReporting']
		if precincts_reporting.nil?
			precincts_reporting = 0
		end
		precincts_total = county['TotalPrecincts']

		ind_row << precincts_reporting
		ind_row << precincts_total
		# Append data to CSV
		CSV.open($csv, "a+") do |csv|
			csv << ind_row
		end
	
	# Close if not military, demo, etc.
	end
end

