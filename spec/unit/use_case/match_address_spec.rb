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
          "uprn" => "1000000011",
          "parent_uprn" => "2000000001",
          "full_address" => "FLAT 2-2, BUILDING 1, 23 COLET PARK, HUMMING CITY, H14 9YA",
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
          "parent_uprn" => "",
          "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
      ]
    end

    let(:find_parents_result) do
      [
        {
          "uprn" => "2000000001",
          "parent_uprn" => "",
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
          "count_tokens_intersect" => 12,
          "building_number_exact" => 1,
        },
      ]
    end

    before do
      allow(find_matches_use_case).to receive(:execute).and_return(find_matches_result)
      allow(find_parents_use_case).to receive(:execute).and_return(find_parents_result)
    end

    context "when calling the FindMatches use case" do
      it "extracts the building numbers before calling the use case" do
        use_case.execute(address:, postcode:)
        expect(find_matches_use_case).to have_received(:execute).with(building_numbers: "1 2 2 23", postcode: anything)
      end

      it "passes the postcode to the use case" do
        use_case.execute(address:, postcode:)
        expect(find_matches_use_case).to have_received(:execute).with(building_numbers: anything, postcode:)
      end
    end

    context "when calling the FindParents use case" do
      it "extracts the parent uprns from the FindMatches result" do
        use_case.execute(address:, postcode:)
        expect(find_parents_use_case).to have_received(:execute).with(uprns: %w[2000000001 2000000001])
      end
    end

    context "when we have an exact match" do
      it "returns the expected result" do
        expect(use_case.execute(address:, postcode:)).to eq(expected_result)
      end
    end

    context "when the input does not have a building number" do
      let(:address) do
        "FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY"
      end

      let(:postcode) do
        "H14 9YA"
      end

      let(:find_matches_result) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "",
            "full_address" => "FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
          {
            "uprn" => "1000000011",
            "parent_uprn" => "",
            "full_address" => "THIRD FLAT, THIRD BUILDING TWO, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "",
            "full_address" => "FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT TWO THIRD BUILDING COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 0,
            "count_building_num_intersect" => 0,
            "count_tokens_intersect" => 10,
          },
          {
            "uprn" => "1000000011",
            "parent_uprn" => "",
            "full_address" => "THIRD FLAT, THIRD BUILDING TWO, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "THIRD FLAT THIRD BUILDING TWO COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 0,
            "count_building_num_intersect" => 0,
            "count_tokens_intersect" => 10,
          },
        ]
      end

      it "returns the expected result not setting building_number_exact" do
        expect(use_case.execute(address:, postcode:)).to eq(expected_result)
      end
    end

    context "when set of potential matches do not have an exact match" do
      let(:address) do
        "FLAT 2, THIRD BUILDING, COLET PARK, HUMMING CITY"
      end

      let(:postcode) do
        "H14 9YA"
      end

      let(:find_matches_result) do
        [
          {
            "uprn" => "1000000011",
            "parent_uprn" => "2000000001",
            "full_address" => "FLAT 2-2, BUILDING 1, 23 COLET PARK, HUMMING CITY, H14 9YA",
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
            "parent_uprn" => "",
            "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:find_parents_result) do
        [
          {
            "uprn" => "2000000001",
            "parent_uprn" => "",
            "full_address" => "2 BUILDING THIRD, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000011",
            "parent_uprn" => "2000000001",
            "full_address" => "FLAT 2-2, BUILDING 1, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT 2 2 BUILDING 1 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 4,
            "count_building_num_intersect" => 1,
            "count_tokens_intersect" => 9,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "FLAT 1, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT 1 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 3,
            "count_building_num_intersect" => 1,
            "count_tokens_intersect" => 9,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT 2 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 3,
            "count_building_num_intersect" => 1,
            "count_tokens_intersect" => 9,
          },
          {
            "uprn" => "2000000001",
            "parent_uprn" => "",
            "full_address" => "2 BUILDING THIRD, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "2 BUILDING THIRD 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 2,
            "count_building_num_intersect" => 1,
            "count_tokens_intersect" => 9,
            "is_parent" => 1,
          },
        ]
      end

      it "returns the expected result" do
        expect(use_case.execute(address:, postcode:)).to eq(expected_result)
      end
    end
  end
end
