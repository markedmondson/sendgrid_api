require 'sendgrid_api'
require 'webmock'
require 'multi_json'
require 'vcr'
require 'pry'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

def config
  {
    api_key:  "api-key",
    api_user: "api-user"
  }
end

Log4r::Logger.global.outputters = Log4r::Outputter.stdout
