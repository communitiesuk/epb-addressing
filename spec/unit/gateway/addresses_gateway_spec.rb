require_relative "../../shared_context/shared_addresses_sample"

describe Gateway::AddressesGateway do
  subject(:gateway) { described_class.new }

  include_context "when accessing addresses table"

  describe "#search_by_building_number_and_postcode" do
    before do
      import_sample_data
    end

    it "returns addresses that contain the building number and postcode" do
      building_numbers = "29"
      postcode = "EX1 2FW"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.rows.length).to eq 1
    end
  end
end
