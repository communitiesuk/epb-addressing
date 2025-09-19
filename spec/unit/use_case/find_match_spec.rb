describe UseCase::FindMatch do
  subject(:use_case) { described_class.new(addresses_gateway:) }

  let(:addresses_gateway) { instance_double Gateway::AddressesGateway }

  describe "#execute" do
    let(:building_numbers) { "29" }
    let(:postcode) { "EX1 2FW" }
    let(:result) do
      [{ "full_address" => "FIFTH FLOOR FLAT 29, THE DEPOT, BAMPFYLDE STREET, EXETER, EX1 2FW", "postcode" => "EX1 2FW", "uprn" => "10094203877", "parent_uprn" => "10094201747" }]
    end

    before do
      allow(addresses_gateway).to receive(:search_by_building_number_and_postcode).and_return(result)
      allow(addresses_gateway).to receive(:search_by_postcode)
    end

    context "when there is a match for the building number and postcode" do
      before do
        use_case.execute(building_numbers:, postcode:)
      end

      it "calls the addresses gateway with the right parameters" do
        expect(addresses_gateway).to have_received(:search_by_building_number_and_postcode).with(building_numbers:, postcode:)
      end

      it "does not call the postcode method" do
        expect(addresses_gateway).not_to have_received(:search_by_postcode)
      end
    end

    context "when there is not a match for the building number and postcode" do
      let(:result) do
        []
      end

      before do
        allow(addresses_gateway).to receive(:search_by_building_number_and_postcode).and_return(result)
        use_case.execute(building_numbers:, postcode:)
      end

      it "calls the postcode only gateway method with the correct arguments" do
        expect(addresses_gateway).to have_received(:search_by_postcode).with(postcode:)
      end
    end

    context "when there are not building numbers" do
      let(:building_numbers) { "" }

      before do
        use_case.execute(building_numbers:, postcode:)
      end

      it "does not call the building and postcode method" do
        expect(addresses_gateway).not_to have_received(:search_by_building_number_and_postcode)
      end

      it "calls the postcode only gateway method with the correct arguments" do
        expect(addresses_gateway).to have_received(:search_by_postcode)
      end
    end
  end
end
