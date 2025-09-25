describe Helper::Results, type: :helper do
  subject(:results_helper) { described_class }

  describe "#merge_parents" do
    context "when merging parents with different addresses" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "2000000002",
            "full_address" => "Some address with parent",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      let(:parents) do
        [
          {
            "uprn" => "2000000002",
            "parent_uprn" => "",
            "full_address" => "Different address on the parent",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      let(:expected) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "2000000002",
            "full_address" => "Some address with parent",
            "postcode" => "IP25 6RE",
          },
          {
            "uprn" => "2000000002",
            "parent_uprn" => "",
            "full_address" => "Different address on the parent",
            "postcode" => "IP25 6RE",
            "is_parent" => 1,
          },
        ]
      end

      it "merges the new parents in the results and adds is_parent to parent results" do
        expect(results_helper.merge_parents(results:, parents:)).to eq(expected)
      end
    end

    context "when merging a parent with the same address" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "Same address parent and child",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      let(:parents) do
        [
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "Same address parent and child",
            "postcode" => "IP25 6RE",
          },
        ]
      end
      let(:expected) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "Same address parent and child",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      it "does not merge the new parent in the results" do
        expect(results_helper.merge_parents(results:, parents:)).to eq(expected)
      end
    end
  end

  describe "#add_clean_address" do
    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
        },
      ]
    end

    let(:results_after_cleaning) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
        },
      ]
    end

    it "adds a clean address to each value in the table" do
      expect(results_helper.add_clean_address(results:)).to eq results_after_cleaning
    end
  end

  describe "#add_tokens_out" do
    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
        },
      ]
    end

    let(:results_after_calculating_tokens_out) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
          "tokens_out" => 3,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
          "tokens_out" => 3,
        },
      ]
    end

    it "adds tokens out to each value in the table" do
      expect(results_helper.add_tokens_out(results:)).to eq results_after_calculating_tokens_out
    end
  end

  describe "#add_building_tokens" do
    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
        },
      ]
    end

    let(:results_with_building_tokens) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "building_tokens" => 2,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
          "building_tokens" => 1,
        },
      ]
    end

    it "returns the number of token in the extracted building numbers" do
      expect(described_class.add_building_tokens(results:)).to eq results_with_building_tokens
    end
  end

  # set LenBuildingNumIntersect
  describe "#add_count_building_num_intersect" do
    let(:extracted_building_number) { "2" }
    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
        },
      ]
    end

    let(:results_with_count_building_num_intersect) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "count_building_num_intersect" => 1,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 SECONDARY ROAD",
          "count_building_num_intersect" => 0,
        },
      ]
    end

    it "returns the number of token in the extracted building numbers" do
      expect(described_class.add_count_building_num_intersect(extracted_building_number:, results:)).to eq results_with_count_building_num_intersect
    end
  end

  # set TokensIntersect
  describe "#add_tokens_intersect" do
    let(:input) { "123 FLAT 2 TEST STREET GREATER MANCHESTER" }
    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "124 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "124 TEST STREET",
        },
      ]
    end
    let(:results_with_count_tokens_intersect) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "count_tokens_intersect" => 5,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
          "count_tokens_intersect" => 3,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "124 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "124 TEST STREET",
          "count_tokens_intersect" => 2,
        },
      ]
    end

    it "returns the number of tokens in the extracted building numbers" do
      expect(described_class.add_tokens_intersect(input:, results:)).to eq results_with_count_tokens_intersect
    end
  end

  describe "#remove_matches" do
    context "when there is only one match" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "123 Flat 2, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "123 FLAT 2 TEST STREET",
            "count_tokens_intersect" => 5,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "123 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "123 TEST STREET",
            "count_tokens_intersect" => 3,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "124 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "124 TEST STREET",
            "count_tokens_intersect" => 2,
          },
        ]
      end
      let(:results_with_least_matches_removed) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "123 Flat 2, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "123 FLAT 2 TEST STREET",
            "count_tokens_intersect" => 5,
          },
        ]
      end

      it "returns the result with the most matches" do
        expect(described_class.remove_matches(results:)).to eq results_with_least_matches_removed
      end
    end

    context "when there are multiple matches" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "1, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "1 TEST STREET",
            "count_tokens_intersect" => 2,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "2 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "2 TEST STREET",
            "count_tokens_intersect" => 2,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "3 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "3 TEST STREET",
            "count_tokens_intersect" => 2,
          },
          {
            "uprn" => "1000000004",
            "parent_uprn" => "",
            "full_address" => "3 Tst Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "3 TST STREET",
            "count_tokens_intersect" => 1,
          },
        ]
      end

      let(:expected_results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "1, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "1 TEST STREET",
            "count_tokens_intersect" => 2,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "2 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "2 TEST STREET",
            "count_tokens_intersect" => 2,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "3 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "3 TEST STREET",
            "count_tokens_intersect" => 2,
          },
        ]
      end

      it "returns the results with the most matches" do
        expect(described_class.remove_matches(results:)).to eq expected_results
      end
    end

    context "when there are no matches" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "1, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "1 TEST STREET",
            "count_tokens_intersect" => 0,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "2 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "2 TEST STREET",
            "count_tokens_intersect" => 0,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "3 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "3 TEST STREET",
            "count_tokens_intersect" => 0,
          },
        ]
      end

      it "returns the results with the most matches" do
        expect(described_class.remove_matches(results:)).to eq results
      end
    end
  end

  # this is when there are building numbers

  describe "#count_exact_numbers_and_not_parents" do
    context "when there are matches" do
      let(:extracted_building_number) { "1 2" }
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "Flat 1, 2, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "FLAT 1 2 TEST STREET",
            "count_tokens_intersect" => 5,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "FLAT 1-2 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "FLAT 1 2 TEST STREET",
            "count_tokens_intersect" => 5,
            "is_parent" => 1,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "FLAT 2 1 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "FLAT 2 1 TEST STREET",
            "count_tokens_intersect" => 5,
          },
        ]
      end

      it "returns the number of matches" do
        expect(described_class.count_exact_numbers_and_not_parents(extracted_building_number:, results:)).to eq 1
      end
    end

    context "when there are no matches" do
      let(:extracted_building_number) { "1 3" }
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "1000000002",
            "full_address" => "Flat 1, 2, Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "FLAT 1 2 TEST STREET",
            "count_tokens_intersect" => 5,
          },
          {
            "uprn" => "1000000002",
            "parent_uprn" => "",
            "full_address" => "FLAT 1-2 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "FLAT 1 2 TEST STREET",
            "count_tokens_intersect" => 5,
            "is_parent" => 1,
          },
          {
            "uprn" => "1000000003",
            "parent_uprn" => "",
            "full_address" => "FLAT 2 1 Test Street, Greater Manchester",
            "postcode" => "IP25 6RE",
            "clean_address" => "FLAT 2 1 TEST STREET",
            "count_tokens_intersect" => 5,
          },
        ]
      end

      it "returns 0" do
        expect(described_class.count_exact_numbers_and_not_parents(extracted_building_number:, results:)).to eq 0
      end
    end
  end

  describe "#remove_non_exact_numbers" do
    let(:extracted_building_number) { "1 2" }

    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "Flat 1, 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "FLAT 1 2 TEST STREET",
          "count_tokens_intersect" => 5,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "FLAT 2 1 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "FLAT 2 1 TEST STREET",
          "count_tokens_intersect" => 5,
        },
      ]
    end

    let(:results_with_only_exact_building_numbers) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "Flat 1, 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "FLAT 1 2 TEST STREET",
          "count_tokens_intersect" => 5,
          "building_number_exact" => 1,
        },
      ]
    end

    it "returns the result with the exact building number and is not a parent uprn" do
      expect(described_class.remove_non_exact_numbers(extracted_building_number:, results:)).to eq results_with_only_exact_building_numbers
    end
  end

  describe "#remove_parents" do
    let(:results) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "Flat 1, 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "FLAT 1 2 TEST STREET",
          "count_tokens_intersect" => 5,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "FLAT 1-2 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "FLAT 1 2 TEST STREET",
          "count_tokens_intersect" => 5,
          "is_parent" => 1,
        },
      ]
    end
    let(:results_without_parents) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "Flat 1, 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "FLAT 1 2 TEST STREET",
          "count_tokens_intersect" => 5,
        },
      ]
    end

    it "returns the result with the exact building number and is not a parent uprn" do
      expect(described_class.remove_parents(results:)).to eq results_without_parents
    end
  end
end
