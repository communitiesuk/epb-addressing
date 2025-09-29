describe Helper::Matching, type: :helper do
  # fn_NumTokensIntersect
  # sets LenBuildingNumIntersect and TokensIntersect
  describe "#count_tokens_intersect" do
    context "when there inputs are identical" do
      let(:identical_strings) { "43 1A" }

      it "returns the correct number of tokens that intersect" do
        expect(described_class.count_tokens_intersect(input: identical_strings, potential_match: identical_strings)).to eq(2)
      end
    end

    context "when there inputs are the same but in a different order" do
      let(:input) { "43 6 1A" }
      let(:potential_match) { "1A 43 6" }

      it "returns the correct number of tokens that intersect" do
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(3)
      end
    end

    context "when there inputs are different" do
      let(:input) { "43 1A" }
      let(:potential_match) { "43" }

      it "returns the correct number of tokens that intersect" do
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(1)
      end
    end

    context "when the extracted building number is empty" do
      let(:input) { "" }
      let(:potential_match) { "43" }

      it "returns 0" do
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(0)
      end
    end

    context "when the potential_match building number is empty" do
      let(:input) { "43 2A" }
      let(:potential_match) { "" }

      it "returns 0" do
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(0)
      end
    end

    context "when both inputs are empty" do
      let(:input) { "" }
      let(:potential_match) { "" }

      it "returns 0" do
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(0)
      end
    end

    context "when there are repeated numbers in the input" do
      it "counts the number once" do
        input = "1 1"
        potential_match = "1"
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(1)
      end

      it "counts all intersecting instances" do
        input = "1 1 1"
        potential_match = "1 1"
        expect(described_class.count_tokens_intersect(input:, potential_match:)).to eq(2)
      end
    end
  end

  # fn_NumTokensMatched
  # sets TokensMatched1
  describe "#count_tokens_matching" do
    context "when the inputs are identical" do
      let(:identical_strings) { "FLAT 43 1A FAKE STREET" }

      it "returns the correct number of tokens that match" do
        expect(described_class.count_tokens_matching(input: identical_strings, potential_match: identical_strings)).to eq(5)
      end
    end

    context "when there are additional words in the potential match" do
      let(:input) { "FLAT 43 1A FAKE STREET" }
      let(:potential_match) { "FLAT 43 BUILDING 1A FAKE STREET" }

      it "returns the correct number of tokens that match" do
        expect(described_class.count_tokens_matching(input:, potential_match:)).to eq(5)
      end
    end

    context "when there are missing words in the potential match" do
      let(:input) { "FLAT 43 1A FAKE STREET" }
      let(:potential_match) { " 43 1A FAKE STREET" }

      it "returns the correct number of tokens that match" do
        expect(described_class.count_tokens_matching(input:, potential_match:)).to eq(4)
      end
    end

    context "when there are repeated words in the potential match" do
      let(:input) { "FLAT FLAT 43 1A FAKE STREET" }
      let(:potential_match) { "FLAT 43 1A FAKE STREET" }

      it "counts the repeated word" do
        expect(described_class.count_tokens_matching(input:, potential_match:)).to eq(6)
      end
    end
  end
end
