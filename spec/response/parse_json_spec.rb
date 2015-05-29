require 'sendgrid_api/response/parse_json'
require 'spec_helper'
require 'json'

module SendgridApi
  module Response
    describe "parse_json" do
      before do
        VCR.turn_off!

        @json = {message: "success"}.to_json
        @auth = {error: {code: 401, message: "Permission denied, wrong credentials"}}.to_json
        @html = '<html><head><title>502 Bad Gateway</title></head><body><h1>502 Bad Gateway</h1></body></html>'

        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/200') { [200, { 'content-type' => 'application/json' }, @json] }
          stub.get('/401') { [200, { 'content-type' => 'application/json' }, @auth] }
          stub.get('/502') { [502, { 'content-type' => 'application/html' }, @html] }
        end

        @conn = Faraday.new do |builder|
          builder.response :sendgrid_api_parse_json
          builder.adapter :test, stubs
        end
      end

      after { VCR.turn_on! }

      describe "#call" do
        context "when called with valid successful json" do
          it "should parse and return the JSON body" do
            response = @conn.get('http://localhost/200')

            response.body.should be_instance_of(Hash)
          end
        end

        context "when the result body contains the status code" do
          it "should set the response status code to that in the body" do
            expect { @conn.get('http://localhost/401') }.to raise_error SendgridApi::Error::AuthenticationError
          end
        end

        context "when called with a HTML response" do
          it "should respect the HTTP headers" do
            expect { @conn.get('http://localhost/502') }.to raise_error SendgridApi::Error::ApiException
          end
        end

        context "when the response cannot be parsed" do
          before {
            @json = "invalid"
          }

          it "should throw an exception and log the error" do
            expect { @conn.get('http://localhost/200') }.to raise_error SendgridApi::Error::ParserError
          end
        end
      end
    end
  end
end
