module Controller
  class MatchAddressController < Controller::BaseController
    POST_SCHEMA = {
      type: "object",
      required: %w[postcode address_line_1 town],
      properties: {
        postcode: {
          type: "string",
        },
        address_line_1: {
          type: "string",
        },
        address_line_2: {
          type: "string",
        },
        address_line_3: {
          type: "string",
        },
        address_line_4: {
          type: "string",
        },
        town: {
          type: "string",
        },
      },
    }.freeze

    post "/match-address" do
      request_body(POST_SCHEMA)
      status 200
    rescue Boundary::Json::ValidationError => e
      json_response({ error: e.message }, 400)
    end
  end
end
