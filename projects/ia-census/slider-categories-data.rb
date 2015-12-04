# In this file, we find all the relevant data for the sliders on our map
# For instance, for population we would need the minand max values, etc.
# We do this by looping through the JSON file with the values for each county
# And finding the appropriate values

require 'json'

# The file data we 
final_data = {}

$file = JSON.parse( File.read("edits/03-census-unemployment-geoid.json") )

# The file has one object for each county
$file.each_with_index do |data, num_data|
	# puts '---', data[1].length

	data[1].each_with_index do |census_data, num_census_data|
		if census_data[0] != "county"
			puts census_data[0]
		end
	end
end