module UseCase
  class MatchAddress
    def initialize(
      find_matches_use_case:,
      find_parents_use_case:
    )
      @find_matches_use_case = find_matches_use_case
      @find_parents_use_case = find_parents_use_case
    end

    def execute(address:, postcode:)
      # Step 0
      building_numbers = Helper::BuildingNumber.extract_building_numbers(address)
      potential_matches = @find_matches_use_case.execute(building_numbers:, postcode:)

      parent_uprns = potential_matches.map { |potential_match| potential_match["parent_uprn"] unless potential_match["parent_uprn"].nil? || potential_match["parent_uprn"].empty? }.compact
      parents = @find_parents_use_case.execute(uprns: parent_uprns)
      Helper::PotentialMatches.merge_parents(potential_matches:, parents:)

      # NumMatchesStage0 will need to be created and tested at some stage
      # num_match_stage_0 = potential_matches.length

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

      # NumMatchesStage1 will need to be created and tested at some stage
      # num_match_stage_1 = potential_matches.length

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

      # FoundCount will need to be created and tested at some stage
      # found_count = potential_matches.length

      # Check if any of the potential matches is an exact match
      # Set eq. IsExactMatch
      Helper::PotentialMatches.add_is_exact_match(input: clean_address, potential_matches:)
      potential_matches
    end
  end
end
