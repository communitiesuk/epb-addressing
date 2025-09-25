module UseCase
  class FindMatches
    def initialize(
      addresses_gateway:
    )
      @addresses_gateway = addresses_gateway
    end

    def execute(building_numbers:, postcode:)
      potential_matches = []
      unless building_numbers.empty?
        potential_matches = @addresses_gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      end
      if potential_matches.empty?
        potential_matches = @addresses_gateway.search_by_postcode(postcode:)
      end
      potential_matches
    end
  end
end
