require 'spec_helper'
require 'json'

module SendgridApi
  describe "client" do
    describe ".initialize" do
      context "by default" do
        subject(:client) { Client.new }

        it "should set the default format to json" do
          subject.format.should == :json
        end

        it "should initialize a logger" do
          subject.logger.should_not be_nil
        end
      end

      it "should allow the default attributes to be set" do
        Client.new(format: :xml).instance_variable_get("@format").should == :xml
        Client.new(config).instance_variable_get("@api_key").should == config[:api_key]
      end

      it "should allow the method be set" do
        Client.new(method: "test").method.should == "test"
      end
    end

    describe ".get" do
      subject(:client) { Client.new(config.merge(method: "customer")) }

      it "should return back a result", :vcr do
        subject.get("profile", "get").should be_kind_of(Result)
      end

      context "with invalid authentication params", :vcr do
        subject(:client) { Client.new(config.merge(api_key: "invalid", method: "customer")) }

        it "should raise an exception" do
          expect { subject.get("profile", "get") }.to raise_error Error::AuthenticationError
        end
      end

      context "with missing path params", :vcr do
        subject(:client) { Client.new(config.merge({method: nil})) }

        it "should raise an exception" do
          expect { subject.get("profile", "get") }.to raise_error ArgumentError
        end
      end

      context "with valid params", :vcr do
        it "should call the requested method" do
          result = subject.get("profile", "get")
          result.success?.should == true
          result.body.should be_a_kind_of(Array)
        end
      end

      context "when the response cannot be parsed" do
        it "should throw an exception and log the error" do
          logger = double(:logger)
          logger.stub(:error).with(an_instance_of(String)) do |error|
            error.should == "Unable to parse Sendgrid API response: SendgridApi::Error::ParserError"
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
