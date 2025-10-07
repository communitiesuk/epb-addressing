describe "Acceptance::MatchAddress" do
  include RSpecAddressingServiceMixin
  context "when getting a response from /match-address" do
    context "when the response is a success" do
      context "when the request has all the inputs" do
        let(:response) do
          post "/match-address",
               { postcode: "SW1A 2AA",
                 address_line_1: "23 Fake Street",
                 address_line_2: "Building 1",
                 address_line_3: "Circular",
                 address_line_4: "Round",
                 town: "Fake Town" }.to_json,
               {
                 "CONTENT_TYPE" => "application/json",
               }
        end

        it "returns a 200 status" do
          expect(response.status).to eq(200)
        end
      end
    end

    context "when the request is missing a required input" do
      let(:response) do
        post "/match-address",
             { address_line_1: "23 Fake Street",
               address_line_2: "Building 1",
               address_line_3: "Circular",
               address_line_4: "Round",
               town: "Fake Town" }.to_json,
             {
               "CONTENT_TYPE" => "application/json",
             }
      end

      it "returns a 400 status" do
        expect(response.status).to eq(400)
      end

      it "explains that a postcode is missing" do
        expect(response.body).to include("postcode")
      end
    end
  end
end
