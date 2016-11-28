require "csv"

results = []

CSV.open("output/count.csv", "w") do |csv|
	# Append header row
	csv << ['Rep', 'Dem', 'None', 'Vacant']

	final_count = Hash.new
		final_count["Rep"] = 0
		final_count["Dem"] = 0
		final_count["None"] = 0
		final_count["Vacant"] = 0

		CSV.foreach('edits/02-ia-boards-filter.csv', headers: true) do |row, index|
			if row["Term Begin"] == nil
				begin_year = nil
			else
				begin_year = Date.strptime(row["Term Begin"], '%Y-%m-%d').year
			end


			if row["Term End"] == nil
				end_year = Date.strptime('2016-12-31').year
			else
				end_year = Date.strptime(row["Term End"], '%Y-%m-%d').year
			end

			if row["Party"] == nil
				party = "None"
			else
				party = row["Party"]
			end


			if row['Status'] != 'V'
				final_count[party] += 1
			else
				final_count["Vacant"] += 1
			end
		
		# Close CSV loop
		end
	
	# Append data to final CSV
	final_row = [final_count['Rep'], final_count['Dem'], final_count['None'], final_count['Vacant']]
	csv << final_row

# Close CSV open
end