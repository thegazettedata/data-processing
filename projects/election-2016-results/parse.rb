require 'nokogiri'
require 'json'

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
  else
  	4
  end
}

@sorted_types.each_with_index do |type, index|
	races = type.xpath('Race')
	type = type.xpath('Type').text

	# p '---'
	# p type
	# p races.length

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

	if (type == 'State Senate' || type == 'State House')
		@final_results[type] = {}
		@final_results[type]['races'] = {}
	end

	# Each race
	races.each_with_index do |race, index_one|
		race_title = race.xpath('RaceTitle').text
		counties = race.xpath('Counties')

		# Start creating our JSON file
		if (type != 'State Senate' && type != 'State House')
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
				if (type != 'State Senate' && type != 'State House')
					@final_results[race_title]['counties'][county_name] = {:r_prec => reporting_precincts, :t_prec => total_precincts}
					@final_results[race_title]['r_prec'] += reporting_precincts
					@final_results[race_title]['t_prec'] += total_precincts
				else
					@final_results[type]['races'][race_title]["r_prec"] += reporting_precincts
					@final_results[type]['races'][race_title]["t_prec"] += total_precincts
				end

				# Each party
				parties.each_with_index do |party, index_four|
					party_name = party.xpath('PartyName').text
					if (party_name.include? 'Democratic')
						party_name = 'D'
					elsif (party_name.include? 'Republican')
						party_name = 'R'
					elsif (party_name.include? 'Green')
						party_name = 'G'
					elsif (party_name.include? 'Libertarian')
						party_name = 'L'
					elsif (party_name.include? 'Independent')
						party_name = 'I'
					end

					party_candidates = party.xpath('Candidate')
					votes_cumulative_county = 0
					
					# Sort candidates by vote count
					sorted_party_candidates = party_candidates.sort_by{ |n|
						n.xpath('YesVotes').text.to_i
					}.reverse

					# This is for all races with county-by-county results
					if (type != 'State Senate' && type != 'State House')
						@final_results[race_title]['counties'][county_name]["candidates"] = {}

						# Sort candidates by vote count
						sorted_party_candidates = party_candidates.sort_by{ |n|
							n.xpath('YesVotes').text.to_i
						}.reverse

						sorted_party_candidates.each_with_index do |candidate, index_five|
							firstname = candidate.xpath('FirstName').text
							lastname = candidate.xpath('LastName').text
							candidate_name = "#{firstname} #{lastname}".strip
							candidate_yes_votes = candidate.xpath('YesVotes').text.to_i

							# Append results for each candidate
							@final_results[race_title]['counties'][county_name]["candidates"][index_five] = {n: candidate_name, v: candidate_yes_votes, p: party_name
							}

							votes_cumulative_county += candidate_yes_votes
						# Close sorted party candidates
						end

						candidates = @final_results[race_title]['counties'][county_name]["candidates"]

						candidates.each_with_index do |i, index_ten|
							percent = ((i[1][:v].to_f / votes_cumulative_county.to_f) * 100).round(1)
							i[1][:per] = percent
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
					else
						@final_results[race_title]["candidates"] = {}
					end

					party_candidates.each_with_index do |candidate, index_five|
						firstname = candidate.xpath('FirstName').text
						lastname = candidate.xpath('LastName').text
						candidate_name = "#{firstname} #{lastname}".strip
						candidate_yes_votes = candidate.xpath('YesVotes').text.to_i

						# Determine if candidate is the cumulative array
						candidates_cumulative.each_with_index do |i, index_six|
							if (i[:n] == candidate_name)
								candidates_cumulative_exists = true
							end
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
								if (candidate_name == 'Donald Trump') 
									description = 'CEO of The Trump Organization'
								elsif (candidate_name == 'Hillary Clinton')
									description = 'Former Secretary of State'
								elsif (candidate_name == 'Jill Stein')
									description = 'Physician'
								elsif (candidate_name == 'Gary Johnson')
									description = 'Businessman'
								end
							elsif ( race_title.include?('United States Senator') || race_title.include?('U.S. Rep.') )
								if (candidate_name == 'Charles E. Grassley' || candidate_name == 'Rod Blum' || candidate_name == 'Dave Loebsack' || candidate_name == 'David Young' || candidate_name == 'Steve King')
									description = 'Incumbent'
								else
									description = 'Challenger'
								end
							end

							if (description === '')
								candidates_cumulative.push( {n: candidate_name, v: candidate_yes_votes, p: party_name} )
							else
								candidates_cumulative.push( {n: candidate_name, v: candidate_yes_votes, p: party_name, d: description} )
							end
						else
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
		votes_cumulative = 0

		candidates_cumulative.each_with_index do |i, index_seven|
			votes_cumulative += i[:v]
		end

		candidates_cumulative.each_with_index do |i, index_eight|
			percent = ((i[:v].to_f / votes_cumulative.to_f) * 100).round(1)
			i[:per] = percent
		end


		# Sort candidates by vote count
		sorted_candidates_cumulative = candidates_cumulative.sort_by{ |n|
			n[:v]
		}.reverse


		if (type == 'State Senate' || type == 'State House')
			r_prec = @final_results[type]['races'][race_title]['r_prec']
			t_prec = @final_results[type]['races'][race_title]['t_prec']

			# Denote winner
			if (r_prec >= t_prec)
				sorted_candidates_cumulative[0]["w"] = true
			end

			@final_results[type]['races'][race_title]["candidates"] = sorted_candidates_cumulative
		else
			r_prec = @final_results[race_title]['r_prec']
			t_prec = @final_results[race_title]['t_prec']

			# Denote winner
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
	@json_file = File.open("output/election-2016-results.json","w")
	@json_file.write(@final_results.to_json)
end