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
	# Data includes state and all counties
	# So we don't want to count the state when coming up with county averages
	file_length = $file.length - 1

	if data[0] != "05000US04000US19"
		data[1].each_with_index do |census_data, num_census_data|

			if census_data[0] != "county"
				category_sub = census_data[0].split('__')
				category = category_sub[0]
				sub_category = category_sub[1]
				value = census_data[1]

				if final_data[category] == nil
					final_data[category] = {'text': category.capitalize.sub('_', ' ').sub('_', ' '), 'text-before': '', 'text-after': ''}
					final_data[category]['categories'] = {}
				end

				if sub_category == nil
					final_data[category]['categories']['subcategories'] = false

				 	if final_data[category]['categories']['min'] == nil or final_data[category]['categories']['min'] > value
				 		final_data[category]['categories']['min'] = value.floor
				 	end

				 	if final_data[category]['categories']['max'] == nil or final_data[category]['categories']['max'] < value
				 		final_data[category]['categories']['max'] = value.ceil
				 	end

				 	# Population is the only category where we want a county average
				 	if category == 'POPULATION'
				 		if final_data[category]['categories']['county-avg'] == nil
				 			final_data[category]['categories']['county-avg'] = value
				 		else
				 			final_data[category]['categories']['county-avg'] += value

				 			if num_data == file_length
								final_data[category]['categories']['county-avg'] = final_data[category]['categories']['county-avg'] / file_length
				 			end
				 		end
				 	else
				 		final_data[category]['categories']['county-avg'] = 0
				 	end

				 	# Grab the state averages for every category
				 	if $file["05000US04000US19"][category] % 1 != 0
				 		final_data[category][:"text-after"] = '%'
				 		state_avg = $file["05000US04000US19"][category].round(1)
				 	else
				 		state_avg = $file["05000US04000US19"][category]
				 	end

				 	final_data[category]['categories']['state-avg'] = state_avg

				 	if category.include? "INCOME"
				 		final_data[category][:"text-before"] = '$'
				 	end
				else
					final_data[category]['categories']['subcategories'] = true
					
					if final_data[category]['categories'][sub_category] == nil
						final_data[category]['categories'][sub_category] = { 'text': sub_category.capitalize.sub('_', ' ').sub('_', ' '), 'county-avg': 0 }
					end

					if final_data[category]['categories'][sub_category]['min'] == nil or final_data[category]['categories'][sub_category]['min'] > value
						final_data[category]['categories'][sub_category]['min'] = value.floor
					end

					if final_data[category]['categories'][sub_category]['max'] == nil or final_data[category]['categories'][sub_category]['max'] < value
				 		final_data[category]['categories'][sub_category]['max'] = value.ceil
				 	end

				 	if $file["05000US04000US19"][category + '__' + sub_category] % 1 != 0
				 		state_avg = $file["05000US04000US19"][category + '__' + sub_category].round(1)
				 	else
				 		state_avg = $file["05000US04000US19"][category + '__' + sub_category]
				 	end

				 	final_data[category]['categories'][sub_category]['state-avg'] = state_avg

				end
			# Close if not county
			end
		# Close data[1] loop
		end
	# Close if not 05000US04000US19
	end
# Close file loop
end

# Output the data to a file
puts "Create file for sliders"

File.open("output/js/base-slider-categories.js", 'w+') { |file|
	file.write("// Info for each category
// Each category is explained

// text
// How you want the category worded on the page

// text_before
// text_after
// Where we store if we want to put any text before or after the range text
// For intance, a dollar sign median household income
// And a percentage sign after race percentages

// WITHIN CATEGORIES

// json-key
// The key in the GeoJSON that equals the current category
// Example: Black population is: RACE_BLACK

// min
// max
// Minimum and maximum values for each category
// Will adjust as reader adjusts slider

// county-avg
// state-avg
// County and state averages for each category

var slider_categories = " + JSON.pretty_generate(final_data))
}