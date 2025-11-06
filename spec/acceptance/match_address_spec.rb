require "sentry-ruby"

describe "Acceptance::MatchAddress" do
  include RSpecAddressingServiceMixin
  context "when getting a response from /match-address" do
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

    context "when requesting a response with no token" do
      let(:response) do
        post "/match-address",
             { postcode: "SW1A 2AA",
               address_line_1: "23 Fake Street",
               address_line_2: "Building 1",
               town: "Fake Town" }.to_json,
             {
               "CONTENT_TYPE" => "application/json",
             }
      end

      it "returns status 401" do
        expect(response.status).to eq(401)
      end

      it "raises an error due to the missing token" do
        expect(response.body).to include Auth::Errors::TokenMissing.to_s
      end
    end

    context "when requesting a response using a token with the wrong scopes" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[bad:scope another:scope])}")
        post "/match-address",
             { postcode: "SW1A 2AA",
               address_line_1: "23 Fake Street",
               address_line_2: "Building 1",
               town: "Fake Town" }.to_json,
             {
               "CONTENT_TYPE" => "application/json",
             }
      end

      it "returns status 403" do
        expect(response.status).to eq(403)
      end

      it "raises an error due to the missing token" do
        expect(response.body).to include "You are not authorised to perform this request"
      end
    end

    context "when the request has a valid token" do
      before do
        header("Authorization", "Bearer #{get_valid_jwt(%w[addressing:read])}")
      end

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

        it "calls the MatchAddress use case and returns expected response" do
          response_body = JSON.parse(response.body)

          expect(match_address_use_case).to have_received(:execute).with(address: "23 Fake Street, Building 1, Circular, Round, Fake Town", postcode: "SW1A 2AA", confidence_threshold: 0)
          expect(response_body["data"]).to eq(match_address_response)
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

      context "when the postcode is invalid" do
        let(:response) do
          post "/match-address",
               { postcode: "S 2AA",
                 address_line_1: "23 Fake Street",
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

        it "returns Invalid Postcode error message" do
          response_body = JSON.parse(response.body)
          expect(response_body["error"]).to eq("Invalid postcode")
        end
      end

      context "when there is an unexpected error" do
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

        before do
          allow(match_address_use_case).to receive(:execute).and_raise StandardError.new("Unexpected Error")
          allow(Sentry).to receive(:capture_exception)
        end

        it "returns a 500 status" do
          expect(response.status).to eq(500)
        end

        it "returns the error message and sends to Sentry" do
          response_body = JSON.parse(response.body)
          expect(response_body["error"]).to eq("Unexpected Error")
          expect(Sentry).to have_received(:capture_exception).once
        end
      end
    end
  end
end
