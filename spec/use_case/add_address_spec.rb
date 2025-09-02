describe UseCase::AddAddress do
  context 'when calling the object in the class' do
    subject { described_class.new }

    it 'can execute' do
      expect(subject.execute).to eq true
    end
  end
end