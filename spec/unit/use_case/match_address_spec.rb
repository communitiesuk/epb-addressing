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

    let(:confidence_threshold) do
      90.0
    end

    let(:find_matches_result) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "2000000001",
          "address" => "FLAT 1-2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000011",
          "parent_uprn" => "2000000001",
          "address" => "FLAT 2-2, BUILDING 1, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "address" => "FLAT 1, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
      ]
    end

    let(:find_parents_result) do
      [
        {
          "uprn" => "2000000001",
          "parent_uprn" => "",
          "address" => "BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "postcode" => postcode,
        },
      ]
    end

    let(:expected_result) do
      [
        {
          "uprn" => "1000000001",
          "address" => "FLAT 1-2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
          "confidence" => 99.88861160,
        },
      ]
    end

    before do
      allow(find_matches_use_case).to receive(:execute).and_return(find_matches_result)
      allow(find_parents_use_case).to receive(:execute).and_return(find_parents_result)
    end

    context "when calling the FindMatches use case" do
      it "extracts the building numbers before calling the use case" do
        use_case.execute(address:, postcode:, confidence_threshold:)
        expect(find_matches_use_case).to have_received(:execute).with(building_numbers: "1 2 2 23", postcode: anything)
      end

      it "passes the postcode to the use case" do
        use_case.execute(address:, postcode:, confidence_threshold:)
        expect(find_matches_use_case).to have_received(:execute).with(building_numbers: anything, postcode:)
      end
    end

    context "when calling the FindParents use case" do
      it "extracts the parent uprns from the FindMatches result" do
        use_case.execute(address:, postcode:, confidence_threshold:)
        expect(find_parents_use_case).to have_received(:execute).with(uprns: %w[2000000001 2000000001])
      end
    end

    context "when calculating the confidence" do
      before do
        allow(Helper::PotentialMatches).to receive(:add_confidence).and_call_original
      end

      it "calls add_confidence with the expected arguments" do
        use_case.execute(address:, postcode:, confidence_threshold:)
        expect(Helper::PotentialMatches).to have_received(:add_confidence).with(
          potential_matches: anything,
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
        expect(use_case.execute(address:, postcode:, confidence_threshold:)).to eq(expected_result)
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
            "address" => "FIVE FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
          {
            "uprn" => "1000000011",
            "parent_uprn" => "",
            "address" => "FOUR THIRD FLAT, THIRD BUILDING TWO, COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000001",
            "address" => "FIVE FLAT TWO, THIRD BUILDING, COLET PARK, HUMMING CITY, H14 9YA",
            "confidence" => 97.14892282,
          },
        ]
      end

      it "returns the expected result not setting building_number_exact" do
        expect(use_case.execute(address:, postcode:, confidence_threshold:)).to eq(expected_result)
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
            "address" => "FLAT 2-2, BUILDING 1, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "address" => "FLAT 1, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:find_parents_result) do
        [
          {
            "uprn" => "2000000001",
            "parent_uprn" => "",
            "address" => "2 BUILDING THIRD, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000003",
            "address" => "FLAT 2, BUILDING 2, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "confidence" => 43.54307280,
          },
        ]
      end

      it "returns the expected result" do
        expect(use_case.execute(address:, postcode:, confidence_threshold: 40)).to eq(expected_result)
      end

      it "returns no results using 50 as a confidence threshold" do
        expect(use_case.execute(address:, postcode:, confidence_threshold: 50)).to eq([])
      end

      it "calls add_confidence with the expected arguments" do
        allow(Helper::PotentialMatches).to receive(:add_confidence).and_call_original
        use_case.execute(address:, postcode:, confidence_threshold: 40)
        expect(Helper::PotentialMatches).to have_received(:add_confidence).with(
          potential_matches: anything,
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
            "address" => "FLAT 1, BUILDING 3, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:find_parents_result) do
        [
          {
            "uprn" => "2000000001",
            "parent_uprn" => "",
            "address" => "FLAT 2, BUILDING 3, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "postcode" => postcode,
          },
        ]
      end

      let(:expected_result) do
        [
          {
            "uprn" => "1000000001",
            "address" => "FLAT 1, BUILDING 3, 23 COLET PARK, HUMMING CITY, H14 9YA",
            "confidence" => 96.65794262,
          },
        ]
      end

      it "removes the parent address" do
        expect(use_case.execute(address:, postcode:, confidence_threshold:)).to eq(expected_result)
      end
    end

    context "when there are no results on stage 0" do
      let(:find_matches_result) { [] }
      let(:find_parents_result) { [] }

      it "does not raise an error" do
        expect { use_case.execute(address:, postcode:, confidence_threshold:) }.not_to raise_error
      end

      it "returns an empty array" do
        expect(use_case.execute(address:, postcode:, confidence_threshold:)).to eq([])
      end
    end
  end
end
