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

    let(:expected_result_without_confidence) do
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
          "count_tokens_matches_1" => 12,
          "count_tokens_matches_2" => 12,
          "tokens_out" => 12,
          "percentage_match" => 1.0,
          "is_exact_match" => 1,
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
          "count_tokens_matches_1" => 12,
          "count_tokens_matches_2" => 12,
          "tokens_out" => 12,
          "percentage_match" => 1.0,
          "is_exact_match" => 1,
          "confidence" => 99.88861160140938,
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

    context "when calculating the confidence" do
      before do
        allow(Helper::PotentialMatches).to receive(:add_confidence)
      end

      it "calls add_confidence with the expected arguments" do
        use_case.execute(address:, postcode:)
        expect(Helper::PotentialMatches).to have_received(:add_confidence).with(
          potential_matches: expected_result_without_confidence,
          tokens_in: 12,
          building_number_found: 1,
          building_number_tokens: 4,
          percent_num_1: 1.0,
          bin_matches_stage_1: 1,
          num_matches_stage_0: 5,
          found_count: 1,
        )
      end
    end

    context "when we have an exact match" do
      it "returns the expected result" do
        expect(use_case.execute(address:, postcode:)).to eq(expected_result)
      end
    end

    context "when the input does not have a building number and has repeated tokens" do
      let(:address) do
        "FOUR-FIVE FLAT TWO, THIRD BUILDING, FIVE COLET PARK, HUMMING CITY"
      end

      let(:postcode) do
        "H14 9YA"
      end

      let(:find_matches_result) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "",
            "full_address" => "FIVE FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
          {
            "uprn" => "1000000011",
            "parent_uprn" => "",
            "full_address" => "FOUR THIRD FLAT, THIRD BUILDING TWO, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "",
            "full_address" => "FIVE FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FIVE FLAT TWO THIRD BUILDING COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 0,
            "count_building_num_intersect" => 0,
            "count_tokens_intersect" => 11,
            "count_tokens_matches_1" => 12,
            "count_tokens_matches_2" => 11,
            "tokens_out" => 11,
            "percentage_match" => 1.0,
            "confidence" => 97.14892282138462,
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

      let(:expected_result_without_confidence) do
        [
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT 2 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 3,
            "count_building_num_intersect" => 1,
            "count_tokens_intersect" => 9,
            "count_tokens_matches_1" => 9,
            "count_tokens_matches_2" => 10,
            "tokens_out" => 11,
            "percentage_match" => 0.9090909090909091,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT 2 BUILDING 2 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 3,
            "count_building_num_intersect" => 1,
            "count_tokens_intersect" => 9,
            "count_tokens_matches_1" => 9,
            "count_tokens_matches_2" => 10,
            "tokens_out" => 11,
            "percentage_match" => 0.9090909090909091,
            "confidence" => 43.54307280490437,
          },
        ]
      end

      it "returns the expected result" do
        expect(use_case.execute(address:, postcode:)).to eq(expected_result)
      end

      it "calls add_confidence with the expected arguments" do
        allow(Helper::PotentialMatches).to receive(:add_confidence)
        use_case.execute(address:, postcode:)
        expect(Helper::PotentialMatches).to have_received(:add_confidence).with(
          potential_matches: expected_result_without_confidence,
          tokens_in: 10,
          building_number_found: 1,
          building_number_tokens: 1,
          percent_num_1: 1.0,
          bin_matches_stage_1: 0,
          num_matches_stage_0: 4,
          found_count: 1,
        )
      end
    end

    context "when there are parents still in the potential matches at stage 3" do
      let(:address) do
        "FLAT 1-2 BUILDING 3, 23 COLET PARK, HUMMING CITY"
      end

      let(:postcode) do
        "H14 9YA"
      end

      let(:find_matches_result) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "2000000001",
            "full_address" => "FLAT 1, BUILDING 3, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:find_parents_result) do
        [
          {
            "uprn" => "2000000001",
            "parent_uprn" => "",
            "full_address" => "FLAT 2, BUILDING 3, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "2000000001",
            "full_address" => "FLAT 1, BUILDING 3, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
            "clean_address" => "FLAT 1 BUILDING 3 23 COLET PARK HUMMING CITY H14 9YA",
            "building_tokens" => 3,
            "count_building_num_intersect" => 3,
            "count_tokens_intersect" => 11,
            "count_tokens_matches_1" => 11,
            "count_tokens_matches_2" => 11,
            "tokens_out" => 11,
            "percentage_match" => 1.0,
            "confidence" => 96.65794262938212,
          },
        ]
      end

      it "removes the parent address" do
        expect(use_case.execute(address:, postcode:)).to eq(expected_result)
      end
    end
  end
end
