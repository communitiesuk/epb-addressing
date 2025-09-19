describe UseCase::MatchAddress do
  subject(:use_case) { described_class.new(find_match_use_case:, find_parents_use_case:) }

  let(:find_match_use_case) do
    instance_double(UseCase::FindMatch)
  end

  let(:find_parents_use_case) do
    instance_double(UseCase::FindParents)
  end

  describe "#execute" do
    let(:address) do
      "1 - 171 LESS CLOSE; 1 - 129 LILY ROAD; AND 27 - 71, COLET PARK, HUMMINGCITY"
    end

    let(:postcode) do
      "H14 9YA"
    end

    let(:find_match_result) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "2000000001",
          "full_address" => "Some address with parent",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "Some other address",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => nil,
          "full_address" => "Some other address with nil parent_uprn",
          "postcode" => postcode,
        },
      ]
    end

    let(:find_parents_result) do
      [
        {
          "uprn" => "2000000001",
          "parent_uprn" => nil,
          "full_address" => "Parent address",
          "postcode" => postcode,
        },
      ]
    end

    let(:expected_result) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "2000000001",
          "full_address" => "Some address with parent",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "Some other address",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => nil,
          "full_address" => "Some other address with nil parent_uprn",
          "postcode" => postcode,
        },
        {
          "uprn" => "2000000001",
          "parent_uprn" => nil,
          "full_address" => "Parent address",
          "postcode" => postcode,
          "is_parent" => 1,
        },
      ]
    end

    before do
      allow(find_match_use_case).to receive(:execute).and_return(find_match_result)
      allow(find_parents_use_case).to receive(:execute).and_return(find_parents_result)
      use_case.execute(address:, postcode:)
    end

    context "when calling the FindMatch use case" do
      it "extracts the building numbers before calling the use case" do
        expect(find_match_use_case).to have_received(:execute).with(building_numbers: "1 171 1 129 27 71", postcode: anything)
      end

      it "passes the postcode to the use case" do
        expect(find_match_use_case).to have_received(:execute).with(building_numbers: anything, postcode:)
      end
    end

    context "when calling the FindParents use case" do
      it "extracts the parent uprns from the FindMatch result" do
        expect(find_parents_use_case).to have_received(:execute).with(uprns: %w[2000000001])
      end
    end

    context "when doing a successful search" do
      it "returns the expected result" do
        expect(find_match_result).to eq(expected_result)
      end
    end
  end
end
