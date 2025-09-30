describe UseCase::MatchAddress do
  subject(:use_case) { described_class.new(find_matches_use_case:, find_parents_use_case:) }

  let(:find_matches_use_case) do
    instance_double(UseCase::FindMatches)
  end

  let(:find_parents_use_case) do
    instance_double(UseCase::FindParents)
  end

  describe "#execute" do
    let(:address) do
      "FLAT 1-2, BUILDING 2, 23 COLET PARK, HUMMING CITY"
    end

    let(:postcode) do
      "H14 9YA"
    end

    let(:find_matches_result) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "2000000001",
          "full_address" => "FLAT 1-2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "FLAT 1, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => nil,
          "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
      ]
    end

    let(:find_parents_result) do
      [
        {
          "uprn" => "2000000001",
          "parent_uprn" => nil,
          "full_address" => "BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
      ]
    end

    let(:expected_result) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "2000000001",
          "full_address" => "FLAT 1-2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
          "clean_address" => "FLAT 1 2 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
          "building_tokens" => 4,
          "count_building_num_intersect" => 4,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "FLAT 1, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
          "clean_address" => "FLAT 1 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
          "building_tokens" => 3,
          "count_building_num_intersect" => 3,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => nil,
          "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
          "clean_address" => "FLAT 2 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
          "building_tokens" => 3,
          "count_building_num_intersect" => 3,
        },
        {
          "uprn" => "2000000001",
          "parent_uprn" => nil,
          "full_address" => "BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
          "is_parent" => 1,
          "clean_address" => "BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
          "building_tokens" => 2,
          "count_building_num_intersect" => 2,
        },
      ]
    end

    before do
      allow(find_matches_use_case).to receive(:execute).and_return(find_matches_result)
      allow(find_parents_use_case).to receive(:execute).and_return(find_parents_result)
      use_case.execute(address:, postcode:)
    end

    context "when calling the FindMatches use case" do
      it "extracts the building numbers before calling the use case" do
        expect(find_matches_use_case).to have_received(:execute).with(building_numbers: "1 2 2 23", postcode: anything)
      end

      it "passes the postcode to the use case" do
        expect(find_matches_use_case).to have_received(:execute).with(building_numbers: anything, postcode:)
      end
    end

    context "when calling the FindParents use case" do
      it "extracts the parent uprns from the FindMatches result" do
        expect(find_parents_use_case).to have_received(:execute).with(uprns: %w[2000000001])
      end
    end

    context "when doing a successful search" do
      it "returns the expected result" do
        expect(find_matches_result).to eq(expected_result)
      end
    end
  end
end
