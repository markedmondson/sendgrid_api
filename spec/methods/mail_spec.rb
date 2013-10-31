require 'spec_helper'

describe "mail" do
  subject(:mail)  { SendgridApi::Mail.new(nil, config) }
  let(:user) { {
    user: "user-test",
  } }
  let(:openclick) { {filters: {openclick: {settings: {enable: 1}}}} }

  describe ".initialize" do
    it "should create an empty xsmtp hash" do
      subject.xsmtp.should <=> {}
    end

    it "should take an xsmtp hash and initialize with it" do
      SendgridApi::Mail.new(nil, config.merge(xsmtp: openclick)).xsmtp.should == openclick
    end

    it "should set the method" do
      subject.options[:method].should == "mail"
    end

    it "should reset the Client endpoint" do
      subject.client.instance_variable_get("@endpoint").should == "https://sendgrid.com/api/"
    end
  end

  describe ".queue", :vcr do
    let(:simple_message) { {from: "from@email.com", to: "to@email.com", subject: "Rspec test", text: "text", html: "html"} }

    it "should throw an error when there are missing params" do
      expect { subject.queue }.to raise_error SendgridApi::Error::OptionsError
    end

    it "should send an email" do
      subject.queue(simple_message)
        .success?.should == true
    end

    it "should remove any empty values" do
      subject.client.should_receive(:post).once.with(
        "send",
        nil,
        simple_message
      )
      subject.queue(simple_message.merge({ bcc: nil, replyto: nil }))
    end

    it "should include x-smtpapi headers" do
      subject.filters(:openclick)
      subject.client.should_receive(:post).once.with(
        "send",
        nil,
        simple_message.merge("x-smtpapi".to_sym => openclick.to_json)
      )
      subject.queue(simple_message)
    end
  end

  describe ".bcc" do
    it "should add the bcc address to the filters" do
      subject.bcc("bcc@email.com")
      subject.xsmtp.should <=> {filters: {bcc: {settings: {email: "bcc@email.com"}}}}
    end
  end

  describe ".enable" do
    it "should add the application to the filters" do
      subject.filters(:openclick)
      subject.xsmtp.should <=> openclick
    end
  end

  describe ".category" do
    it "should add the application to the filters" do
      subject.category("something/something")
      subject.xsmtp.should <=> {category: ["something/something"]}
    end
  end

  describe ".unique_args" do
    it "should add the application to the filters" do
      subject.unique_args(message_status_id: "1234")
      subject.xsmtp.should == {unique_args: {message_status_id: "1234"}}
    end
  end
end
