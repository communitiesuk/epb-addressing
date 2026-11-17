# frozen_string_literal: true

describe "Acceptance::Server" do
  include RSpecAddressingServiceMixin

  context "when an uncaught error is raised" do
    let(:app) do
      Class.new(AddressingService) do
        set :raise_errors, false
        set :show_exceptions, false

        get "/test-error" do
          raise "boom"
        end
      end
    end

    before do
      get "/test-error"
    end

    it "responds with a 500 status" do
      expect(last_response.status).to eq 500
    end

    it "displays a verbose error message" do
      expect(JSON.parse(last_response.body)).to eq("backtrace" => [], "message" => "boom", "type" => "RuntimeError")
    end
  end
end
