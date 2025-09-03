require "active_support"
require "active_support/core_ext"
require "sentry-ruby"
require "sinatra/activerecord"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.setup

class Addresses < ActiveRecord::Base
end
