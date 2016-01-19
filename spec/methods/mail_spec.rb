require 'spec_helper'

describe "mail" do
  subject(:mail)  { SendgridApi::Mail.new(nil, config) }
  let(:user) { {
    user: "user-test",
  } }
  let(:openclick) { {filters: {openclick: {settings: {enable: 1}}}} }

  describe ".initialize" do
    it "should create an empty xsmtp hash" do
      expect(subject.xsmtp).to eq({})
    end

    it "should take an xsmtp hash and initialize with it" do
      expect(SendgridApi::Mail.new(nil, config.merge(xsmtp: openclick)).xsmtp).to eq openclick
    end

    it "should set the method" do
      expect(subject.options[:method]).to eq "mail"
    end

    it "should reset the Client endpoint" do
      expect(subject.client.instance_variable_get("@endpoint")).to eq "https://sendgrid.com/api/"
    end
  end

  describe ".queue", vcr: true do
    let(:message) { {from: "from@email.com", to: "mark@guestfolio.com", subject: "Rspec test", text: "text", html: "html"} }

    it "should throw an error when there are missing params" do
      expect { subject.queue }.to raise_error SendgridApi::Error::OptionsError
    end

    it "should send an email" do
      expect(subject.queue(message).success?).to eq true
    end

    it "should remove any empty values" do
      expect(subject.client).to receive(:post).once.with(
        "send",
        nil,
        message
      )
      subject.queue(message.merge({ bcc: nil, replyto: nil }))
    end

    it "should include x-smtpapi headers" do
      subject.filters(:openclick)
      expect(subject.client).to receive(:post).once.with(
        "send",
        nil,
        message.merge("x-smtpapi".to_sym => openclick.to_json)
      )
      subject.queue(message)
    end
  end

  describe ".bcc" do
    it "should add the bcc address to the filters" do
      subject.bcc("bcc@email.com")
      expect(subject.xsmtp).to eq({filters: {bcc: {settings: {email: "bcc@email.com"}}}})
    end
  end

  describe ".enable" do
    it "should add the application to the filters" do
      subject.filters(:openclick)
      expect(subject.xsmtp).to eq openclick
    end
  end

  describe ".category" do
    it "should add the application to the filters" do
      subject.category("something/something")
      expect(subject.xsmtp).to eq({category: ["something/something"]})
    end
  end

  describe ".unique_args" do
    it "should add the application to the filters" do
      subject.unique_args(message_status_id: "1234")
      expect(subject.xsmtp).to eq({unique_args: {message_status_id: "1234"}})
    end
  end
end
