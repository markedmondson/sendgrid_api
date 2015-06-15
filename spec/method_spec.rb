require 'spec_helper'

module SendgridApi
  describe "method" do
    subject(:method) { Method.new }

    describe ".initialize" do
      context "by default" do
        it "should initialize a new client" do
          expect(Method.new.client).to be_kind_of(Client)
        end

        it "should pass through options to the client" do
          expect(SendgridApi::Method.new(nil, config).client.instance_variable_get("@api_key")).to eq "api-key"
        end

        context "when the client is already initialized" do
          let(:client) { Client.new }

          it "should intiialize using the existing client" do
            expect(Method.new(client).client).to eq client
          end
        end
      end
    end
  end
end
