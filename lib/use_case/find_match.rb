module UseCase
  class FindMatch
    def initialize(
      addresses_gateway:
    )
      @addresses_gateway = addresses_gateway
    end

    def execute(building_numbers:, postcode:)
      result = @addresses_gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      if result.empty?
        result = @addresses_gateway.search_by_postcode(postcode:)
      end
      result
    end
  end
end
