# Grab arguments
ARGV.each_with_index do |argument, num|
	# Our JSON file
	if num == 0
		$file_path = argument
		$data = File.read("#{argument}")
	end
end

# Remove spaces
new_data = $data.gsub(" ", "")

# Create new file path
new_file_path = $file_path.gsub("json/", "json/min/")
puts new_file_path
# Save to new file
File.open(new_file_path, "w") {|file| file.puts new_data }
