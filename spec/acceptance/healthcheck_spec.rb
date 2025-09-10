describe "Acceptance::Healthcheck" do
  include RSpecAddressingServiceMixin
  context "when getting a response from /healthcheck" do
    let(:response) { get "/healthcheck" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end
  end
end
