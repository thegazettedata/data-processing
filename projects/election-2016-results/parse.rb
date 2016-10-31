require 'nokogiri'
require 'json'
require 'open-uri'
require 'fileutils'
require 'date'

# Scrape the SOS site to get find the latest XML file on their site
# @source = open('http://electionresultsiowa.com/xml/index.html', &:read)
# @noko = Nokogiri::HTML(@source)
# @xml = @noko.css(".results tr:nth-of-type(2) td:nth-of-type(2) a").first.text

# # Open that XML file and save it locally
# open("http://electionresultsiowa.com/xml/#{@xml}") {|f|
# 	File.open("output/election-2016-results.xml","wb") do |file|
# 		file.puts f.read
# 	end
# }

# Convert XML to JSON
@doc = Nokogiri::XML(File.open("output/election-2016-results.xml"))
@types = @doc.xpath('/ElectionResults/ElectionInfo/TypeRace')
@final_results = Hash.new

# Make sure we have the types properly sorted
@sorted_types = @types.sort_by{ |n|
	type = n.xpath('Type').text

  case
  when type == 'Federal'
    0
  when type == 'Congressional'
    1
  when type == 'State Senate'
  	2
  when type == 'State House'
    3
  when type == 'Judicial'
  	4
  else
  	5
  end
}

@sorted_types.each_with_index do |type, index|
	races = type.xpath('Race')
	type = type.xpath('Type').text

	# Make sure Presidential race comes first
	sorted_races = races.sort_by{ |n|
		title = n.xpath('RaceTitle').text

		case
		when title.include?('President')
		  0
		when title.include?('United States Senator')
		  1
		else
			2
		end
	}

	if (type == 'State Senate' || type == 'State House'|| type == 'Judicial')
		@final_results[type] = {}
		@final_results[type]['races'] = {}
		
		# Incumbents
		if (type == 'State Senate')
			@final_results[type]['candidates'] = {
				'D': 13,
				'R': 10,
				'I': 1,
				'V': 1
			}
		elsif (type == 'State House')
			@final_results[type]['candidates'] = {
				'D': 0,
				'R': 0,
				'I': 0
			}
		end
	end

	# Each race
	races.each_with_index do |race, index_one|
		race_title = race.xpath('RaceTitle').text
		race_title.slice! " and Vice President"
		counties = race.xpath('Counties')

		# Break up district and judge's name
		if (type == 'Judicial')
			if race_title.include? 'Assoc'
				race_title_split = race_title.split(' Assoc. ')
				judge_name = "Assoc. #{race_title_split[1]}"
			elsif race_title.include? 'Judge'
				race_title_split = race_title.split(' Judge ')
				judge_name = "Judge #{race_title_split[1]}"
			end

			race_title = race_title_split[0]
		end


		# Start creating our JSON file
		if (type != 'State Senate' && type != 'State House' && type != 'Judicial')
			@final_results[race_title] = {}
			@final_results[race_title]['counties'] = {}
			@final_results[race_title]['r_prec'] = 0
			@final_results[race_title]['t_prec'] = 0
		else
			@final_results[type]['races'][race_title] = {}
			@final_results[type]['races'][race_title]["r_prec"] = 0
			@final_results[type]['races'][race_title]["t_prec"] = 0
		end

		# Combine votes for each candidate
		# We do this for races were we want cumulative results
		# Like state races
		candidates_cumulative = []
		candidates_cumulative_exists = false

		# Each county
		counties.each_with_index do |county, index_two|
			county_name = county.xpath('CountyName').text
			county_results = county.xpath('CountyResults')

			# Each result for each county
			county_results.each_with_index do |result, index_three|
				reporting_precincts = result.xpath('ReportingPrecincts').text.to_i
				total_precincts = result.xpath('TotalPrecincts').text.to_i
				parties = result.xpath('Party')

				# Append data for each county
				if (type != 'State Senate' && type != 'State House' && type != 'Judicial')
					@final_results[race_title]['counties'][county_name] = {:r_prec => reporting_precincts, :t_prec => total_precincts}
					@final_results[race_title]['r_prec'] += reporting_precincts
					@final_results[race_title]['t_prec'] += total_precincts
				else
					@final_results[type]['races'][race_title]["r_prec"] += reporting_precincts
					@final_results[type]['races'][race_title]["t_prec"] += total_precincts
				end

				# Each party
				parties.each_with_index do |party, index_four|
					party = result.xpath('Party')
					party_candidates = party.xpath('Candidate')

					votes_cumulative_county = 0

					# This is for all races with county-by-county results
					if (type != 'State Senate' && type != 'State House' &&  type != 'Judicial')
						@final_results[race_title]['counties'][county_name]["candidates"] = {}

						# Set party and name
						sorted_party_candidates = party_candidates.sort_by{ |n|
							-n.xpath('YesVotes').text.to_i
						}

						sorted_party_candidates.each_with_index do |candidate, index_five|
							firstname = candidate.xpath('FirstName').text
							lastname = candidate.xpath('LastName').text
							if lastname.include? '&'
								lastname = lastname.slice(0..(lastname.index(' &')))
							end
							candidate_name = "#{firstname} #{lastname}".strip
							candidate_yes_votes = candidate.xpath('YesVotes').text.to_i

							# Set party name
							party_name = candidate.parent.xpath('PartyName').children

							if !party_name.nil?
								party_name = party_name.text

								# Abbreviate party name
								if (party_name.include? 'Democratic')
									party_name = 'D'
								elsif (party_name.include? 'Republican')
									party_name = 'R'
								elsif (party_name.include? 'Green')
									party_name = 'G'
								elsif (party_name.include? 'Libertarian')
									party_name = 'L'
								elsif (party_name == 'Independent')
									party_name = 'I'
								end
							else
								party_name = ''
							end

							@final_results[race_title]['counties'][county_name]["candidates"][index_five] = {n: candidate_name, v: candidate_yes_votes, p: party_name}

							votes_cumulative_county += candidate_yes_votes
						# Close party candidates
						end

						# Add percentage of votes
						candidates = @final_results[race_title]['counties'][county_name]["candidates"]

						candidates.each_with_index do |i, index_ten|
							percent = ((i[1][:v].to_f / votes_cumulative_county.to_f) * 100).round(1)
							if !percent.nan?
								i[1][:per] = percent
							else
								i[1][:per] = 0
							end 
						end

						# Declare winner
						if (@final_results[race_title]['counties'][county_name][:r_prec] >= @final_results[race_title]['counties'][county_name][:t_prec])
							@final_results[race_title]['counties'][county_name]["candidates"][0]['w'] = true;
						end

					# Close if
					end

					# This is for all races with overall results
					if (type == 'State Senate' || type == 'State House')
						@final_results[type]['races'][race_title]["candidates"] = {}
					elsif (type != 'Judicial')
						@final_results[race_title]["candidates"] = {}
					end

					party_candidates.each_with_index do |candidate, index_five|
						firstname = candidate.xpath('FirstName').text
						lastname = candidate.xpath('LastName').text
						if lastname.include? '&'
							lastname = lastname.slice(0..(lastname.index(' &')))
						end
						candidate_name = "#{firstname} #{lastname}".strip
						candidate_yes_votes = candidate.xpath('YesVotes').text.to_i

						# Determine if candidate is the cumulative array
						candidates_cumulative.each_with_index do |i, index_six|
							if (i[:n] == candidate_name)
								candidates_cumulative_exists = true
							end
						end

						# Get party name
						party_name = candidate.parent.xpath('PartyName').children

						if !party_name.nil?
							party_name = party_name.text
							
							# Abbreviate party name
							if (party_name.include? 'Democratic')
								party_name = 'D'
							elsif (party_name.include? 'Republican')
								party_name = 'R'
							elsif (party_name.include? 'Green')
								party_name = 'G'
							elsif (party_name.include? 'Libertarian')
								party_name = 'L'
							elsif (party_name == 'Independent')
								party_name = 'I'
							end
						else
							party_name = ''
						end

						length = candidates_cumulative.length

						# This either creates a new object for a candidate in the cumulative array
						# If the candidate is not in that array
						# Or it adds the vote total for this candidate
						# To its value, which is already in the array
						if (!candidates_cumulative_exists)

							# Describe the candidate
							description = ''
							if (race_title == 'President')
								# Trump
								if (candidate_name == 'Donald J. Trump') 
									description = 'Republican nominee'
								# Clinton
								elsif (candidate_name == 'Hillary Clinton')
									description = 'Democratic nominee'
								# Stein
								elsif (candidate_name == 'Jill Stein')
									description = 'Green Party nominee'
								# Johnson
								elsif (candidate_name == 'Gary Johnson')
									description = 'Libertarian nominee'
								# Castle
								elsif (candidate_name == 'Darrell L. Castle')
									description = 'Constitution Party nominee'
								# Vacek
								elsif (candidate_name == 'Dan R. Vacek')
									description = 'Legal Marijuana Now nominee'
								# Kahn
								elsif (candidate_name == 'Lynn Kahn')
									description = 'New Independent Party nominee'
								# La Riva
								elsif (candidate_name == 'Gloria La Riva')
									description = 'Party for Socialism and Liberation nominee'
								# De La Fuente
								elsif (candidate_name == 'Rocky Roque De La Fuente' || candidate_name == 'Evan McMullin')
									description = 'Nominated by petition'
								end
							elsif ( race_title.include?('US Senator') || race_title.include?('US Rep.') )
								# Incumbents: Reps
								if (candidate_name == 'Charles E. Grassley' || candidate_name == 'Rod Blum' || candidate_name == 'David Young' || candidate_name == 'Steve King')
									description = 'Incumbent - Republican Party'
								# Incumbents: Dems
								elsif (candidate_name == 'Dave Loebsack')
									description = 'Incumbent - Democratic Party'
								
								# Challengers: Reps
								elsif (candidate_name == 'Christopher Peters')
									description = 'Challenger - Republican Party'
								# Challengers: Dems
								elsif (candidate_name == 'Patty Judge' || candidate_name == 'Monica Vernon' || candidate_name == 'Jim Mowrer' || candidate_name == 'Kim Weaver')
									description = 'Challenger - Democratic Party'
								# Challengers: Libs
								elsif (candidate_name == 'Charles Aldrich' || candidate_name == 'Bryan Jack Holder')
									description = 'Challenger - Libertarian Party'
								# Challengers: Ind
								elsif (candidate_name == 'Jim Hennager')
									description = 'Challenger - New Independent Party'
								else
									description = 'Challenger'
								end
							end

							if (description === '')
								if (type != 'Judicial')
									candidates_cumulative.push( {n: candidate_name, v: candidate_yes_votes, p: party_name} )
								else
									candidates_cumulative.push( {n: candidate_name, v: candidate_yes_votes} )
								end
							else
								if (candidate_name.include? 'McMullin')
									party_name = "Independent - McMullin"
								elsif (candidate_name.include? 'De La Fuente')
									party_name = "Independent - De La Fuente"
								elsif (candidate_name.include? 'Luick-Thrams')
									party_name = "Independent - Luick-Thrams"
								elsif (candidate_name.include? 'Addy')
									party_name = "Independent - Addy"
								elsif (candidate_name.include? 'Grandanette')
									party_name = "Independent - Grandanette"
								end

								candidates_cumulative.push( {n: candidate_name, v: candidate_yes_votes, p: party_name, d: description} )
							end
						# Add up cumulative votes
						elsif index_four == 0
							index_num = candidates_cumulative.index { |i| i[:n] == candidate_name }
							candidates_cumulative[index_num][:v] += candidate_yes_votes
						end

					# Close each party candidates
					end
				# Close each party
				end
			# Close each result for county
			end

		# Close each county
		end

		# Figure out percent of votes each candidate received
		if (type != 'Judicial')
			votes_cumulative = 0

			candidates_cumulative.each_with_index do |i, index_seven|
				votes_cumulative += i[:v]
			end

			candidates_cumulative.each_with_index do |i, index_eight|
				percent = ((i[:v].to_f / votes_cumulative.to_f) * 100).round(1)
				if !percent.nan?
					i[:per] = percent
				else
					i[:per] = 0
				end 
			end
		end

		# Sort candidates by vote count
		sorted_candidates_cumulative = candidates_cumulative.sort_by{ |n|
			-n[:v]
		}

		if (type == 'State Senate' || type == 'State House' || type == 'Judicial')
			r_prec = @final_results[type]['races'][race_title]['r_prec']
			t_prec = @final_results[type]['races'][race_title]['t_prec']

			# Denote winner
			if (r_prec >= t_prec)
				sorted_candidates_cumulative[0]["w"] = true
				
				# Keep track of balance of power in House, Senate
				if (type != 'Judicial')
					party = sorted_candidates_cumulative[0][:p]

					if party == 'D'
						@final_results[type]['candidates'][:D] += 1;
					elsif party == 'R'
						@final_results[type]['candidates'][:R] += 1;
					else
						@final_results[type]['candidates'][:I] += 1;
					end
				end
			end

			# State House, State Senate
			if (type != 'Judicial')
				@final_results[type]['races'][race_title]["candidates"] = sorted_candidates_cumulative
			# Judicial
			else
				@final_results[type]['races'][race_title]["name"] = judge_name

				if (sorted_candidates_cumulative[0][:n] == "YES")
					yes_votes = sorted_candidates_cumulative[0][:v]
					no_votes = sorted_candidates_cumulative[1][:v]
				else
					yes_votes = sorted_candidates_cumulative[1][:v]
					no_votes = sorted_candidates_cumulative[0][:v]
				end

				@final_results[type]['races'][race_title]["Y"] = yes_votes
				@final_results[type]['races'][race_title]["N"] = no_votes

				r_prec = @final_results[type]['races'][race_title]['r_prec']
				t_prec = @final_results[type]['races'][race_title]['t_prec']

				if (r_prec >= t_prec)
					if (yes_votes > no_votes)
						@final_results[type]['races'][race_title]["w"] = true
					elsif (yes_votes < no_votes)
						@final_results[type]['races'][race_title]["w"] = false
					end
				end
			end
		else
			r_prec = @final_results[race_title]['r_prec']
			t_prec = @final_results[race_title]['t_prec']

			# Denote winner
			if type == 'Judicial'
				p race_title
			end

			if (r_prec >= t_prec)
				sorted_candidates_cumulative[0]["w"] = true
			end

			@final_results[race_title]["candidates"] = sorted_candidates_cumulative
		end

	# Close each race
	end
# Close each type of race
end

# Our final JSON file
if @final_results.length > 0
	# Make copy of old file before overwriting new file
	FileUtils.cp("output/election-2016-results.json", "output/old/results-#{DateTime.now.strftime("%m%d-%H%M")}.json")

	@json_file = File.open("output/election-2016-results.json","w")
	@json_file.write(@final_results.to_json)
end