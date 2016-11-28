require "csv"

results = []

CSV.open("edits/02-ia-boards-filter.csv", "w") do |csv|

	CSV.foreach('edits/01-ia-boards.csv', headers: true) do |row, index|
		if $. == 2
			new_headers = []
			row.headers.each do |header|
				# Remove funky characters
				if header == 'Board/Commission'
					header = 'BoardCommission'
				elsif header == 'Term End↓'
					header = 'Term End'
				end

				new_headers.push(header)
			end

			csv << new_headers
		end

		if row['Board/Commission'].include?('Judicial Nominating')
			csv << row
		end
	end
end