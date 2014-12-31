require 'spec_helper'

module SendgridApi
  describe "method" do
    subject(:method) { Method.new }

    describe ".initialize" do
      context "by default" do
        it "should initialize a new client" do
          Method.new.client.should be_kind_of(Client)
        end

        it "should pass through options to the client" do
          SendgridApi::Method.new(nil, config).client.instance_variable_get("@api_key") == "api_key"
        end

        context "when the client is already initialized" do
          let(:client) { Client.new }

          it "should intiialize using the existing client" do
            Method.new(client).client.should eq(client)
          end
        end
      end
    end
  end
end
