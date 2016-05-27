require "rubygems"
require "bundler/setup"

require 'sendgrid_api'
require 'webmock'
require 'vcr'
require 'pry'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.filter_run_excluding performance: true
end

def config
  {
    api_key:  "api-key",
    api_user: "api-user"
  }
end
