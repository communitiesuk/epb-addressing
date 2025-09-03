require "bundler"
Bundler.require
require "sinatra/activerecord/rake"

ENV["DATABASE_URL"] = "postgresql://localhost:5432/epb-addressing-test" if ENV["DATABASE_URL"].nil? && ENV["STAGE"].nil?
