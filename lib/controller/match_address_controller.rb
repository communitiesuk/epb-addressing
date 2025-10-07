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
      parsed_body = request_body(POST_SCHEMA)

      match_address_use_case = Container.match_address_use_case

      postcode = Helper::Postcode.validate(parsed_body[:postcode])

      address_array = [
        parsed_body[:address_line_1],
        parsed_body[:address_line_2],
        parsed_body[:address_line_3],
        parsed_body[:address_line_4],
        parsed_body[:town],
      ]

      address = address_array.compact.join(", ")

      matches = match_address_use_case.execute(address:, postcode:, confidence_threshold: 50)
      json_api_response code: 200, data: matches
    rescue Boundary::Json::ValidationError => e
      json_response({ error: e.message }, 400)
    rescue Errors::PostcodeNotValid
      json_response({ error: "Invalid postcode" }, 400)
    end
  end
end
