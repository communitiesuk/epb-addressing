module UseCase
  class MatchAddress
    def initialize(
      find_matches_use_case:,
      find_parents_use_case:
    )
      @find_matches_use_case = find_matches_use_case
      @find_parents_use_case = find_parents_use_case
    end

    def execute(address:, postcode:, confidence_threshold:)
      # Step 0
      building_numbers = Helper::BuildingNumber.extract_building_numbers(address)
      potential_matches = @find_matches_use_case.execute(building_numbers:, postcode:)

      parent_uprns = potential_matches.map { |potential_match| potential_match["parent_uprn"] unless potential_match["parent_uprn"].nil? || potential_match["parent_uprn"].empty? }.compact
      parents = @find_parents_use_case.execute(uprns: parent_uprns)
      Helper::PotentialMatches.merge_parents(potential_matches:, parents:)

      # Set eq. NumMatchesStage0
      num_matches_stage_0 = potential_matches.length

      # Set clean address eq. CleanAddress2 for each row
      Helper::PotentialMatches.add_clean_address(potential_matches:)

      # Set eq. LenBuildingNum2
      Helper::PotentialMatches.add_building_tokens(potential_matches:)

      # Set eq. LenBuildingNumIntersect
      Helper::PotentialMatches.add_count_building_num_intersect(extracted_building_number: building_numbers, potential_matches:)

      # Step 1 - find out how many intersecting tokens there are and only return the ones with the most matches

      # eq. @SearchString and CleanAddress1
      clean_address = Helper::Address.clean_address_string("#{address}, #{postcode}")

      # Set eq. TokensIntersect
      Helper::PotentialMatches.add_tokens_intersect(input: clean_address, potential_matches:)

      # Retain only the matches with most matching tokens in the address
      Helper::PotentialMatches.remove_matches(potential_matches:, attribute_name: "count_tokens_intersect")

      # Check if any of the matches have the same extracted building numbers only if we have a building number
      if !building_numbers.empty? && Helper::PotentialMatches.count_exact_numbers_and_not_parents(extracted_building_number: building_numbers, potential_matches:).positive?
        Helper::PotentialMatches.remove_non_exact_numbers(extracted_building_number: building_numbers, potential_matches:)
      end

      # Set eq. NumMatchesStage1
      num_matches_stage_1 = potential_matches.length

      # Step 2
      # Calculate the number of tokens in the clean input which are also in each potential match
      # Set eq. TokensMatched1
      Helper::PotentialMatches.add_tokens_matches_1(input: clean_address, potential_matches:)

      # Retain only the matches when comparing count_tokens_matches_1
      Helper::PotentialMatches.remove_matches(potential_matches:, attribute_name: "count_tokens_matches_1")

      # Step 3
      # Calculate the number of tokens in each potential match which are also in the clean input
      # Set eq. TokensMatched2
      Helper::PotentialMatches.add_tokens_matches_2(input: clean_address, potential_matches:)

      # Calculate tokens_out
      # Set eq. TokensOut
      Helper::PotentialMatches.add_tokens_out(potential_matches:)

      # Calculate percentage_match based on count_tokens_matches_2
      Helper::PotentialMatches.add_percentage_match(potential_matches:)

      # Retain only the matches with the highest percentage_match
      Helper::PotentialMatches.remove_matches(potential_matches:, attribute_name: "percentage_match")

      # If there are non-parent matches, discard the parent matches
      Helper::PotentialMatches.cleanup_parents(potential_matches:)

      # Set eq. FoundCount
      found_count = potential_matches.length

      # Check if any of the potential matches is an exact match
      # Set eq. IsExactMatch
      Helper::PotentialMatches.add_is_exact_match(input: clean_address, potential_matches:)

      # Additional values needed for Confidence calculation

      # Set eq. TokensIn
      tokens_in = Helper::Address.calculate_tokens(clean_address)
      # Set eq. of @BuildingNumFound
      building_number_found = !building_numbers.empty? ? 1 : 0
      # Set eq. LenBuildingNum1, doesn't need to go on each match
      building_number_tokens = Helper::Address.calculate_tokens(building_numbers)
      # Set eq. @bin1
      # SQL equivalent checks if num_matches_stage_1 is 1
      # The algorithm document says we should check if num_matches_stage_1 is greater than 1
      bin_matches_stage_1 = num_matches_stage_1 == 1 ? 1 : 0

      # Calculate percentage of intersecting building numbers
      # Set eq. @percentNum1
      percent_num_1 = 1.0

      unless building_numbers.empty?
        # SQL equivalent uses a non-deterministic way of picking the following value,
        # we do think @percentNum1 should be calculated per potential match.
        potential_matches[0]["count_building_num_intersect"] / # eq. LenBuildingNumIntersect
          building_number_tokens.to_f
      end

      # Calculate confidence
      Helper::PotentialMatches.add_confidence(
        potential_matches:,
        tokens_in:,
        building_number_found:,
        building_number_tokens:,
        percent_num_1:,
        bin_matches_stage_1:,
        num_matches_stage_0:,
        found_count:,
      )

      # Remove the potential matches that don't meet the threshold
      Helper::PotentialMatches.remove_by_confidence(potential_matches:, confidence_threshold:)
      potential_matches
    end
  end
end
