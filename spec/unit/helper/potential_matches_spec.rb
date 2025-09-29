describe Helper::PotentialMatches, type: :helper do
  subject(:potential_matches_helper) { described_class }

  describe "#merge_parents" do
    context "when merging parents with different addresses" do
      let(:potential_matches) do
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

      it "merges the new parents in the potential_matches and adds is_parent to parent results" do
        expect(potential_matches_helper.merge_parents(potential_matches:, parents:)).to eq(expected)
      end
    end

    context "when merging a parent with the same address" do
      let(:potential_matches) do
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

      it "does not merge the new parent in the potential_matches" do
        expect(potential_matches_helper.merge_parents(potential_matches:, parents:)).to eq(expected)
      end
    end
  end

  describe "#add_clean_address" do
    let(:potential_matches) do
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

    let(:potential_matches_after_cleaning) do
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
      expect(potential_matches_helper.add_clean_address(potential_matches:)).to eq potential_matches_after_cleaning
    end
  end

  describe "#add_tokens_out" do
    let(:potential_matches) do
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

    let(:potential_matches_after_calculating_tokens_out) do
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
      expect(potential_matches_helper.add_tokens_out(potential_matches:)).to eq potential_matches_after_calculating_tokens_out
    end
  end

  describe "#add_building_tokens" do
    let(:potential_matches) do
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

    let(:potential_matches_with_building_tokens) do
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
      expect(potential_matches_helper.add_building_tokens(potential_matches:)).to eq potential_matches_with_building_tokens
    end
  end

  # set LenBuildingNumIntersect
  describe "#add_count_building_num_intersect" do
    let(:extracted_building_number) { "2" }
    let(:potential_matches) do
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

    let(:potential_matches_with_count_building_num_intersect) do
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
      expect(potential_matches_helper.add_count_building_num_intersect(extracted_building_number:, potential_matches:)).to eq potential_matches_with_count_building_num_intersect
    end
  end

  # set TokensIntersect
  describe "#add_tokens_intersect" do
    let(:input) { "123 FLAT 2 TEST STREET GREATER MANCHESTER" }
    let(:potential_matches) do
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
    let(:potential_matches_with_count_tokens_intersect) do
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
      expect(potential_matches_helper.add_tokens_intersect(input:, potential_matches:)).to eq potential_matches_with_count_tokens_intersect
    end
  end

  describe "#remove_matches" do
    context "when the attribute name is count_tokens_intersect" do
      let(:attribute_name) { "count_tokens_intersect" }

      context "when there is a single result with the maximum number of token intersects" do
        let(:potential_matches) do
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
        let(:potential_matches_with_least_matches_removed) do
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
          expect(potential_matches_helper.remove_matches(potential_matches:, attribute_name:)).to eq potential_matches_with_least_matches_removed
        end
      end

      context "when there are several results with the maximum number of token intersects" do
        let(:potential_matches) do
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

        let(:expected_potential_matches) do
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

        it "returns the potential_matches with the most matches" do
          expect(potential_matches_helper.remove_matches(potential_matches:, attribute_name:)).to eq expected_potential_matches
        end
      end

      context "when there are no matches" do
        let(:potential_matches) do
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

        it "returns the potential_matches with the most matches" do
          expect(potential_matches_helper.remove_matches(potential_matches:, attribute_name:)).to eq potential_matches
        end
      end
    end

    context "when the attribute name is count_tokens_matches_1" do
      let(:attribute_name) { "count_tokens_matches_1" }

      context "when there is a single result with the maximum number of token intersects" do
        let(:potential_matches) do
          [
            {
              "uprn" => "1000000001",
              "parent_uprn" => "1000000002",
              "full_address" => "123 Flat 2, Test Street, Greater Manchester",
              "postcode" => "IP25 6RE",
              "clean_address" => "123 FLAT 2 TEST STREET",
              "count_tokens_matches_1" => 5,
            },
            {
              "uprn" => "1000000002",
              "parent_uprn" => "",
              "full_address" => "123 Test Street, Greater Manchester",
              "postcode" => "IP25 6RE",
              "clean_address" => "123 TEST STREET",
              "count_tokens_matches_1" => 3,
            },
            {
              "uprn" => "1000000003",
              "parent_uprn" => "",
              "full_address" => "124 Test Street, Greater Manchester",
              "postcode" => "IP25 6RE",
              "clean_address" => "124 TEST STREET",
              "count_tokens_matches_1" => 2,
            },
          ]
        end
        let(:potential_matches_with_least_matches_removed) do
          [
            {
              "uprn" => "1000000001",
              "parent_uprn" => "1000000002",
              "full_address" => "123 Flat 2, Test Street, Greater Manchester",
              "postcode" => "IP25 6RE",
              "clean_address" => "123 FLAT 2 TEST STREET",
              "count_tokens_matches_1" => 5,
            },
          ]
        end

        it "returns the result with the most matches" do
          expect(potential_matches_helper.remove_matches(potential_matches:, attribute_name:)).to eq potential_matches_with_least_matches_removed
        end
      end
    end
  end

  # this is when there are building numbers

  describe "#count_exact_numbers_and_not_parents" do
    context "when there are matches" do
      let(:extracted_building_number) { "1 2" }
      let(:potential_matches) do
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
        expect(potential_matches_helper.count_exact_numbers_and_not_parents(extracted_building_number:, potential_matches:)).to eq 1
      end
    end

    context "when there are no matches" do
      let(:extracted_building_number) { "1 3" }
      let(:potential_matches) do
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
        expect(potential_matches_helper.count_exact_numbers_and_not_parents(extracted_building_number:, potential_matches:)).to eq 0
      end
    end
  end

  describe "#remove_non_exact_numbers" do
    let(:extracted_building_number) { "1 2" }

    let(:potential_matches) do
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

    let(:potential_matches_with_only_exact_building_numbers) do
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
      expect(potential_matches_helper.remove_non_exact_numbers(extracted_building_number:, potential_matches:)).to eq potential_matches_with_only_exact_building_numbers
    end
  end

  describe "#remove_parents" do
    let(:potential_matches) do
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
    let(:potential_matches_without_parents) do
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
      expect(potential_matches_helper.remove_parents(potential_matches:)).to eq potential_matches_without_parents
    end
  end

  # TokensMatched1
  describe "#add_token_matches_1" do
    let(:input) { "123 FLAT 2 TEST STREET GREATER MANCHESTER" }
    let(:potential_matches) do
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
    let(:potential_matches_with_count_tokens_matches) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "count_tokens_matches_1" => 5,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
          "count_tokens_matches_1" => 3,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "124 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "124 TEST STREET",
          "count_tokens_matches_1" => 2,
        },
      ]
    end

    it "returns the number of tokens in the extracted building numbers" do
      expect(potential_matches_helper.add_tokens_matches_1(input:, potential_matches:)).to eq potential_matches_with_count_tokens_matches
    end
  end

  # TokensMatched2
  describe "#add_token_matches_2" do
    let(:input) { "123 FLAT 2 TEST STREET GREATER MANCHESTER" }
    let(:potential_matches) do
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
    let(:potential_matches_with_count_tokens_matches) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "count_tokens_matches_2" => 5,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
          "count_tokens_matches_2" => 3,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "124 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "124 TEST STREET",
          "count_tokens_matches_2" => 2,
        },
      ]
    end

    it "returns the number of tokens in the extracted building numbers" do
      expect(potential_matches_helper.add_tokens_matches_2(input:, potential_matches:)).to eq potential_matches_with_count_tokens_matches
    end
  end

  describe "#add_percentage_match" do
    let(:potential_matches) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "tokens_out" => 5,
          "count_tokens_matches_2" => 5,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
          "tokens_out" => 3,
          "count_tokens_matches_2" => 3,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "124 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "124 TEST STREET",
          "tokens_out" => 3,
          "count_tokens_matches_2" => 2,
        },
      ]
    end
    let(:potential_matches_with_percentage_matches) do
      [
        {
          "uprn" => "1000000001",
          "parent_uprn" => "1000000002",
          "full_address" => "123 Flat 2, Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 FLAT 2 TEST STREET",
          "tokens_out" => 5,
          "count_tokens_matches_2" => 5,
          "percentage_match" => 1.0,
        },
        {
          "uprn" => "1000000002",
          "parent_uprn" => "",
          "full_address" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "123 TEST STREET",
          "tokens_out" => 3,
          "count_tokens_matches_2" => 3,
          "percentage_match" => 1.0,
        },
        {
          "uprn" => "1000000003",
          "parent_uprn" => "",
          "full_address" => "124 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "clean_address" => "124 TEST STREET",
          "tokens_out" => 3,
          "count_tokens_matches_2" => 2,
          "percentage_match" => 0.6666666666666666,
        },
      ]
    end

    it "adds percentage match float to each result" do
      expect(potential_matches_helper.add_percentage_match(potential_matches:)).to eq potential_matches_with_percentage_matches
    end
  end

  describe "#cleanup_parents" do
    context "when there are potential matches that are not parents" do
      let(:potential_matches) do
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
      let(:potential_matches_without_parents) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "2000000002",
            "full_address" => "Some address with parent",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      it "removes parents" do
        expect(potential_matches_helper.cleanup_parents(potential_matches:)).to eq potential_matches_without_parents
      end
    end

    context "when all the potential matches are parents" do
      let(:potential_matches) do
        [
          {
            "uprn" => "1000000001",
            "parent_uprn" => "2000000002",
            "full_address" => "Some address with parent",
            "postcode" => "IP25 6RE",
            "is_parent" => 1,
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
      let(:expected_potential_matches) do
        potential_matches.deep_dup
      end

      it "does not delete any parent" do
        expect(potential_matches_helper.cleanup_parents(potential_matches:)).to eq expected_potential_matches
      end
    end

    context "when all the potential matches are not parents" do
      let(:potential_matches) do
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
          },
        ]
      end
      let(:expected_potential_matches) do
        potential_matches.deep_dup
      end

      it "does not delete any parent" do
        expect(potential_matches_helper.cleanup_parents(potential_matches:)).to eq expected_potential_matches
      end
    end
  end
end
