describe UseCase::FindParents do
  subject(:use_case) { described_class.new(addresses_gateway:) }

  let(:addresses_gateway) { instance_double Gateway::AddressesGateway }

  describe "#execute" do
    let(:uprns) { %w[10091906164 10091906123 10091906123] }

    before do
      allow(addresses_gateway).to receive(:search_by_uprns)
      use_case.execute(uprns:)
    end

    it "removes any duplicated uprns" do
      unique_uprns = %w[10091906164 10091906123]
      expect(addresses_gateway).to have_received(:search_by_uprns).with(uprns: unique_uprns)
    end

    it "calls the search_by_uprns method once when multiple uprns are passed" do
      expect(addresses_gateway).to have_received(:search_by_uprns).exactly(:once)
    end
  end
end
