require "bundler"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"

ENV["DATABASE_URL"] = "postgresql://localhost:5432/epb_addressing_test" if ENV["DATABASE_URL"].nil? && ENV["STAGE"].nil?

Dir.glob("lib/tasks/**/*.rake").each { |r| load r }
