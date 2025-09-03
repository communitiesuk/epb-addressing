describe UseCase::AddAddress do
  context "when calling the object in the class" do
    subject(:use_case) { described_class.new }

    it "can execute" do
      expect(use_case.execute).to be true
    end
  end
end
