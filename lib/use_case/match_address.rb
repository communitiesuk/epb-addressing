module UseCase
  class MatchAddress
    def initialize(
      find_match_use_case:,
      find_parents_use_case:
    )
      @find_match_use_case = find_match_use_case
      @find_parents_use_case = find_parents_use_case
    end

    def execute(address:, postcode:)
      building_numbers = Helper::BuildingNumber.extract_building_numbers(address)
      results = @find_match_use_case.execute(building_numbers:, postcode:)

      parent_uprns = results.map { |row| row["parentuprn"] unless row["parentuprn"].nil? || row["parentuprn"].empty? }.compact
      parents = @find_parents_use_case.execute(uprns: parent_uprns)
      Helper::Results.merge_parents(results: results, parents: parents)
    end
  end
end
