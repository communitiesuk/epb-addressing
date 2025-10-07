class Container
  def self.addresses_gateway
    @addresses_gateway ||= Gateway::AddressesGateway.new
  end

  def self.find_matches_use_case
    @find_matches_use_case ||= UseCase::FindMatches.new(addresses_gateway:)
  end

  def self.find_parents_use_case
    @find_parents_use_case ||= UseCase::FindParents.new(addresses_gateway:)
  end

  def self.match_address_use_case
    @match_address_use_case ||= UseCase::MatchAddress.new(find_matches_use_case:, find_parents_use_case:)
  end
end
