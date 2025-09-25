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
      building_numbers = Helper::BuildingNumber.extract_building_numbers(address)
      potential_matches = @find_matches_use_case.execute(building_numbers:, postcode:)

      parent_uprns = potential_matches.map { |potential_match| potential_match["parent_uprn"] unless potential_match["parent_uprn"].nil? || potential_match["parent_uprn"].empty? }.compact
      parents = @find_parents_use_case.execute(uprns: parent_uprns)
      Helper::PotentialMatches.merge_parents(potential_matches:, parents:)
    end
  end
end
