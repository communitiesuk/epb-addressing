require_relative "../../shared_context/shared_addresses_sample"

describe Gateway::AddressesGateway do
  subject(:gateway) { described_class.new }

  include_context "when accessing addresses table"

  before(:all) do
    import_sample_data
  end

  describe "#search_by_building_number_and_postcode" do
    it "returns 1 match that contain the building number and postcode" do
      building_numbers = "29"
      postcode = "EX1 2FW"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.length).to eq 1
    end

    it "returns the correct values" do
      building_numbers = "29"
      postcode = "EX1 2FW"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.first.keys.sort).to eq %w[address parent_uprn postcode uprn]
    end

    it "returns more than one match that contain the building number and postcode" do
      building_numbers = "4"
      postcode = "EX4 4GX"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.length).to eq 3
    end

    it "returns 0 when there is no matches containing the building number and postcode" do
      building_numbers = "1111"
      postcode = "B61 4GX"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.length).to eq 0
    end

    it "returns matches when there are multiple building numbers and postcode" do
      building_numbers = "14 48"
      postcode = "EX4 4EP"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.length).to eq 1
    end

    it "returns matches when the building number includes a letter" do
      building_numbers = "6A"
      postcode = "EX4 1RB"
      result = gateway.search_by_building_number_and_postcode(building_numbers:, postcode:)
      expect(result.length).to eq 1
    end
  end

  describe "#search_by_postcode" do
    it "returns all the matches that contain the postcode" do
      postcode = "EX4 4GX"
      result = gateway.search_by_postcode(postcode:)
      expect(result.length).to eq 6
    end

    it "returns the correct values" do
      postcode = "EX1 2FW"
      result = gateway.search_by_postcode(postcode:)
      expect(result.first.keys.sort).to eq %w[address parent_uprn postcode uprn]
    end

    it "returns 0 when there are no matches that contain the postcode" do
      postcode = "B61 4GX"
      result = gateway.search_by_postcode(postcode:)
      expect(result.length).to eq 0
    end
  end

  describe "#search_by_uprns" do
    let(:uprns) { %w[10091906164 10094201178] }
    let(:result) { gateway.search_by_uprns(uprns:) }

    it "returns any matches" do
      expect(result.length).to eq 2
      expect(result.map { |row| row["uprn"] }.sort).to eq uprns
    end

    it "returns the correct values" do
      expect(result.first.keys.sort).to eq %w[address parent_uprn postcode uprn]
    end

    it "does not return any values for a missing uprn" do
      missing_uprns = %w[1009000000]
      result = gateway.search_by_uprns(uprns: missing_uprns)
      expect(result.length).to eq 0
    end

    it "does not fail if passing an empty array of uprns" do
      expect { gateway.search_by_uprns(uprns: []) }.not_to raise_error
    end

    it "does not return any values if passing an empty array of uprns" do
      result = gateway.search_by_uprns(uprns: [])
      expect(result.length).to eq 0
    end
  end
end
