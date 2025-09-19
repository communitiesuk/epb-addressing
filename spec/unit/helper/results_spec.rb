describe Helper::Results, type: :helper do
  subject(:results_helper) { described_class }

  describe "#merge_parents" do
    context "when merging parents with different addresses" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parentuprn" => "1000000002",
            "fulladdress" => "Some address with parent",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      let(:parents) do
        [
          {
            "uprn" => "1000000002",
            "parentuprn" => "",
            "fulladdress" => "Different address on the parent",
            "postcode" => "IP25 6RE",
          },
        ]
      end
      let(:expected) do
        [
          {
            "uprn" => "1000000001",
            "parentuprn" => "1000000002",
            "fulladdress" => "Some address with parent",
            "postcode" => "IP25 6RE",
          },
          {
            "uprn" => "1000000002",
            "parentuprn" => "",
            "fulladdress" => "Different address on the parent",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      it "merges the new parents in the results" do
        expect(results_helper.merge_parents(results:, parents:)).to eq(expected)
      end
    end

    context "when merging a parent with the same address" do
      let(:results) do
        [
          {
            "uprn" => "1000000001",
            "parentuprn" => "1000000002",
            "fulladdress" => "Same address parent and child",
            "postcode" => "IP25 6RE",
          },
        ]
      end

      let(:parents) do
        [
          {
            "uprn" => "1000000002",
            "parentuprn" => "",
            "fulladdress" => "Same address parent and child",
            "postcode" => "IP25 6RE",
          },
        ]
      end
      let(:expected) do
        [
          {
            "uprn" => "1000000001",
            "parentuprn" => "1000000002",
            "fulladdress" => "Same address parent and child",
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
          "parentuprn" => "1000000002",
          "fulladdress" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
        },
        {
          "uprn" => "1000000002",
          "parentuprn" => "",
          "fulladdress" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
        },
      ]
    end

    let(:results_after_cleaning) do
      [
        {
          "uprn" => "1000000001",
          "parentuprn" => "1000000002",
          "fulladdress" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "cleanaddress" => "123 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parentuprn" => "",
          "fulladdress" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "cleanaddress" => "123 SECONDARY ROAD",
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
          "parentuprn" => "1000000002",
          "fulladdress" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "cleanaddress" => "123 TEST STREET",
        },
        {
          "uprn" => "1000000002",
          "parentuprn" => "",
          "fulladdress" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "cleanaddress" => "123 SECONDARY ROAD",
        },
      ]
    end

    let(:results_after_calculating_tokens_out) do
      [
        {
          "uprn" => "1000000001",
          "parentuprn" => "1000000002",
          "fulladdress" => "123 Test Street, Greater Manchester",
          "postcode" => "IP25 6RE",
          "cleanaddress" => "123 TEST STREET",
          "tokens_out" => 3,
        },
        {
          "uprn" => "1000000002",
          "parentuprn" => "",
          "fulladdress" => "123 Secondary Rd",
          "postcode" => "IP25 6RE",
          "cleanaddress" => "123 SECONDARY ROAD",
          "tokens_out" => 3,
        },
      ]
    end

    it "adds tokens out to each value in the table" do
      expect(results_helper.add_tokens_out(results:)).to eq results_after_calculating_tokens_out
    end
  end
end
