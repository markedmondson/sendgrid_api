require 'spec_helper'
require 'benchmark'

RUN_TIMES = 2

module SendgridApi
  describe "performance" do
    let(:big_str) { (0...500000).map{ ('a'..'z').to_a[rand(26)] }.join }
    let(:message)     { {from: "from@email.com", to: "to@email.com", subject: "Rspec test", html: big_str} }

    before { big_str; message; }

    describe "#mail" do
      subject(:mail)  { Mail.new(nil, config) }
      let(:simple_message) { {from: "from@email.com", to: "to@email.com", subject: "Rspec test", html: big_str} }

      before { subject; simple_message; } # Pre-initialize

      it "should perform send on big strings" do
        time = 0
        RUN_TIMES.times do
          time += Benchmark.realtime {
            subject.post("send", nil, simple_message)
          }
        end
        (time / RUN_TIMES).should < 0.25
      end
    end

    describe "#client" do
      subject(:client)  { Client.new(config.merge(method: "mail")) }

      before { subject; } # Pre-initialize

      it "should perform post on big strings" do
        subject.instance_variable_set("@action", "send")
        time = 0
        RUN_TIMES.times do
          time += Benchmark.realtime {
            subject.send(:request, :post, message)
          }
        end
        (time / RUN_TIMES).should < 0.25
      end
    end

    describe "#faraday" do
      context "params" do
        let(:params)     { Faraday::Utils::ParamsHash[message] }

        before { params }

        it "should url encode the hash" do
          Benchmark.realtime {
            params.to_query
          }.should < 0.10
        end
      end

      context "client" do
        subject(:client) { Client.new(config) }

        before { client }

        it "should initialize" do
          Benchmark.realtime {
            client.send(:connection)
          }.should < 0.10
        end

        it "should post" do
          connection = client.send(:connection)

          Benchmark.realtime {
            connection.post("mail.send.json", message)
          }.should < 0.25
        end

        it "should post with vcr", :vcr do
          connection = client.send(:connection)

          Benchmark.realtime {
            connection.post("mail.send.json", message)
          }.should < 0.25
        end
      end
    end

    describe "#sendgrid" do
      subject(:mailer) { ::Mail::Sendgrid.new }
      let(:html_part)  {
        Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body big_str
        end
      }
      let(:text_part)  {
        Mail::Part.new do
          body big_str
        end
      }
      let(:filter)   {
        {filters: {opentrack: {settings: {enable: 1}}}, clicktrack: {settings: {enable: 1}}, another: {settings: {enable: 0}}}.to_json
      }
      let(:mail)       {
        ::Mail.new(
          from:     '"Tester" <from@address.com>', # Or just "Tester" <from@address.com>
          to:       "to@address.com",
          subject:  "Rspec test",
          headers:  {"X-SMTPAPI" => filter}
        ) do
            text_part { text_part }
            html_part { html_part }
          end
      }
      let(:result) { Result.new({result: "success"}) }

      before { subject; mail; } # Pre-initialize

      it "should render a message" do
        expect_any_instance_of(Mail).to receive(:queue) { result }

        Benchmark.realtime {
          subject.deliver!(mail)
        }.should < 0.05
      end
    end

    describe "#parse_json" do
      it "should parse a response" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/test') { [200, {}, { message: "success" }.to_json] }
        end

        connection = Faraday.new do |builder|
          builder.adapter :test, stubs
          builder.use Response::ParseJson
        end

        expect_any_instance_of(Response::ParseJson).to receive(:call).at_least(:once).and_call_original()

        time = 0
        RUN_TIMES.times do
          time += Benchmark.realtime {
            connection.get("/test")
          }
        end
        (time / RUN_TIMES).should < 0.05
      end
    end
  end
end
