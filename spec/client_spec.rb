require 'spec_helper'
require 'json'

module SendgridApi
  describe "client" do
    describe ".initialize" do
      context "by default" do
        subject(:client) { Client.new }

        it "should set the default format to json" do
          expect(subject.format).to eq :json
        end

        it "should initialize a logger" do
          expect(subject.logger).not_to be_nil
        end
      end

      it "should allow the default attributes to be set" do
        expect(Client.new(format: :xml).instance_variable_get("@format")).to eq :xml
        expect(Client.new(config).instance_variable_get("@api_key")).to eq config[:api_key]
      end

      it "should allow the method be set" do
        expect(Client.new(method: "test").method).to eq "test"
      end
    end

    describe ".get" do
      subject(:client) { Client.new(config.merge(method: "customer")) }

      it "should return back a result", vcr: true do
        expect(subject.get("profile", "get")).to be_kind_of(Result)
      end

      context "with invalid authentication params", vcr: true do
        subject(:client) { Client.new(config.merge(api_key: "invalid", method: "customer")) }

        it "should raise an exception" do
          expect { subject.get("profile", "get") }.to raise_error Error::AuthenticationError
        end
      end

      context "with missing path params", vcr: true do
        subject(:client) { Client.new(config.merge({method: nil})) }

        it "should raise an exception" do
          expect { subject.get("profile", "get") }.to raise_error ArgumentError
        end
      end

      context "with valid params", vcr: true do
        it "should call the requested method" do
          result = subject.get("profile", "get")
          expect(result.success?).to eq true
          expect(result.body).to be_a_kind_of(Array)
        end
      end

      context "when the response cannot be parsed" do
        it "should throw an exception and log the error" do
          logger = double(:logger)
          logger.stub(:error).with(an_instance_of(String)) do |error|
            expect(error).to eq "Unable to parse Sendgrid API response: SendgridApi::Error::ParserError"
          end
          logger.stub(:debug)

          subject = Client.new(config.merge(method: "customer", logger: logger))

          expect_any_instance_of(Faraday::Connection).to receive(:get) { raise SendgridApi::Error::ParserError }
          expect { subject.get("profile", "get") }.to raise_error SendgridApi::Error::ParserError
        end
      end
    end

    describe ".post" do
      # See .get
    end
  end
end
