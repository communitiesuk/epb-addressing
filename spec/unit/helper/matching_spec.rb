describe Helper::Matching, type: :helper do
  describe "#count_tokens_intersect" do
    context "when comparing numbers" do
      context "when there inputs are identical" do
        let(:identical_strings) { "43 1A" }

        it "returns the correct number of tokens that match" do
          expect(described_class.count_tokens_intersect(input: identical_strings, result: identical_strings)).to eq(2)
        end
      end

      context "when there inputs are the same but in a different order" do
        let(:input) { "43 6 1A" }
        let(:result) { "1A 43 6" }

        it "returns the correct number of tokens that match" do
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(3)
        end
      end

      context "when there inputs are different" do
        let(:input) { "43 1A" }
        let(:result) { "43" }

        it "returns the correct number of tokens that match" do
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(1)
        end
      end

      context "when the extracted building number is empty" do
        let(:input) { "" }
        let(:result) { "43" }

        it "returns 0" do
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(0)
        end
      end

      context "when the result building number is empty" do
        let(:input) { "43 2A" }
        let(:result) { "" }

        it "returns 0" do
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(0)
        end
      end

      context "when both inputs are empty" do
        let(:input) { "" }
        let(:result) { "" }

        it "returns 0" do
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(0)
        end
      end

      context "when there are repeated numbers in the input" do
        it "counts the number once" do
          input = "1 1"
          result = "1"
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(1)
        end

        it "counts all matching instances" do
          input = "1 1 1"
          result = "1 1"
          expect(described_class.count_tokens_intersect(input:, result:)).to eq(2)
        end
      end
    end
  end
end
