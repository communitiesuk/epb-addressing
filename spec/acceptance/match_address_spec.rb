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

        let(:match_address_use_case) do
          instance_double(UseCase::MatchAddress)
        end

        let(:match_address_response) do
          [
            {
              "uprn" => "100000000001",
              "address" => "23 FAKE STREET, BUILDING 1, CIRCULAR, ROUND, FAKE TOWN, SW1A 2AA",
              "confidence" => "99.12314",
            },
          ]
        end

        before do
          allow(Container).to receive(:match_address_use_case).and_return(match_address_use_case)
          allow(match_address_use_case).to receive(:execute).and_return(match_address_response)
        end

        it "returns a 200 status" do
          expect(response.status).to eq(200)
        end

        it "calls the MatchAddress use case and returns expected response" do
          response_body = JSON.parse(response.body)

          expect(match_address_use_case).to have_received(:execute).with(address: "23 Fake Street, Building 1, Circular, Round, Fake Town", postcode: "SW1A 2AA", confidence_threshold: 50)
          expect(response_body["data"]).to eq(match_address_response)
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
