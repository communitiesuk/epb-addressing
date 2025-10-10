require "sinatra/base"
require "epb-auth-tools"

module Controller
  class BaseController < Sinatra::Base
    def initialize(app = nil, **_kwargs)
      super
      @json_helper = Helper::JsonHelper.new
    end

    configure :development do
      set :host_authorization, { permitted_hosts: %w[] }
    end

    set(:auth_token_has_all) do |*scopes|
      condition do
        token = Auth::Sinatra::Conditional.process_request env
        unless token.scopes?(scopes)
          content_type :json
          halt 403, { errors: [{ code: "UNAUTHORISED", title: "You are not authorised to perform this request" }] }.to_json
        end
        env[:auth_token] = token
      rescue Auth::Errors::Error => e
        content_type :json
        halt 401, { errors: [{ code: e }] }.to_json
      end
    end

    def request_body(schema)
      @json_helper.convert_to_ruby_hash(request.body.read.to_s, schema:)
    end

    def json_api_response(
      code: 200,
      data: {}
    )
      response_data = { data: }
      json_response(response_data, code)
    end

    def json_response(object, code = 200)
      content_type :json
      status code
      convert_to_json(object)
    end

    def convert_to_json(hash)
      JSON.parse(hash.to_json).deep_transform_keys { |k|
        k.camelize(:lower)
      }.to_json
    end

    def send_to_sentry(exception)
      Sentry.capture_exception(exception) if defined?(Sentry)
    end
  end
end
