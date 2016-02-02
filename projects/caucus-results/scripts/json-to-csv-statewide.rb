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
	elsif num == 2
		$party = argument
	end
end

# Detects if we're appended the header row in our CSV file
header_appended = false

# Create empty array and append CSV header values
# These will include candidate names
header_row = []
candidates_array = []

# Loop through each result
# And append header row
$data['StateResults'].each_with_index do |result, num_result|
	# Loop through each candidate
	if result.length > 0
		candidates_array << result['Candidate']['LastName']
	end
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

# Number of candidates
num_of_candidates = candidates_array.length

# Create empty array for our row of data
ind_row = []

# Fill CSV with blank data
for i in 1..num_of_candidates
	ind_row << 0
end

ind_row << ''

# With the header created, we will now append actual data
$data['StateResults'].each_with_index do |candidate, num_candidate|

	# Name of candidate
	name = candidate['Candidate']['LastName']
	# If this candidate is the winner
	is_winner = candidate['IsWinner']

	# Detects the column number in the CSV
	# For this particular candidate
	candidate_index = header_row.index(name)

	# Format the result to percentages
	# And append to CSV
	if $party == 'iagop'
		# Percentage of the vote for this candidate
		result = candidate['Result']
		result_format = result
	else
		# Percentage of the vote for this candidate
		result = candidate['WinPercentage']
		
		if !result.nil?
			result_format = (result * 100).round(1)
		else
			result_format = 0
		end
	end

	ind_row[candidate_index] = result_format

	# Append winning candidate information
	if is_winner
		ind_row[ind_row.length - 1] = name
	end
end

# Append precincts
precincts_reporting = $data['PrecinctsReporting']
if precincts_reporting.nil?
	precincts_reporting = 0
end
precincts_total = $data['TotalPrecincts']

ind_row << precincts_reporting
ind_row << precincts_total

# Append data to CSV
CSV.open($csv, "a+") do |csv|
	csv << ind_row
end