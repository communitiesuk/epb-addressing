require "active_support"
require "active_support/core_ext"
require "sinatra/activerecord"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.setup

environment = ENV['STAGE']
unless %w[development].include? environment
  Sentry.init do |config|
    config.include_local_variables = true
    config.environment = environment
  end
  use Sentry::Rack::CaptureExceptions
end

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
ActiveSupport.to_time_preserves_timezone = :zone

run AddressingService
