require 'json'

final_data = {}
# Grab arguments
# First will be the Census, unemployment data
# Second will be the geojson file
ARGV.each_with_index do |file, num|
	if num == 0
		$data = JSON.parse( File.read("#{file}") )
	else
		$geojson = JSON.parse( File.read("#{file}") )
	end
end

# Where we will story the final geojson file
# With merged Census, unemployment data
$final_geojson = {}

# Loop through Census, unemployment data
$data.each_with_index do |data, num_data|
	geoid_data = data[0]
	county_data = data[1]

	# Loop through geojson data
	$geojson.each_with_index do |geojson, num_geojson|
		$final_geojson = $geojson

		# Not even really sure what the first iteration is
		# But we don't want it
		if num_geojson == 1
			geojson[1].each_with_index do |geojson_features, num_geojson_features|
				properties = geojson_features['properties']
				geoid_geojson = properties['geoid']
				
				# Match Census data with geojson data
				if geoid_data == geoid_geojson
					$final_geojson['features'][num_geojson_features]['properties'] = properties.merge(county_data)
				end

			end
		end
	end
end

# Create final geojson file
puts "Creating geojson file in outputs directory"

File.open("output/ia-counties-census.json", 'w+') { |file|
	file.write($final_geojson)
}
