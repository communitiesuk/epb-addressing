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

      # Set eq. TokensIntersect
      clean_address = Helper::Address.clean_address_string("#{address}, #{postcode}")
      Helper::PotentialMatches.add_tokens_intersect(input: clean_address, potential_matches:)

      # Retain only the matches with most matching tokens in the address
      Helper::PotentialMatches.remove_matches(potential_matches:, attribute_name: "count_tokens_intersect")

      potential_matches
    end
  end
end
