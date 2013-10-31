require 'spec_helper'

module Mail
  describe "sendgrid" do
    subject(:mailer) { Sendgrid.new }

    describe ".initialize" do
      it "should initialize a new SendgridApi::Client" do
        subject.client.should be_kind_of(SendgridApi::Client)
      end
    end

    describe ".deliver!" do
      let(:filter)   {
        {filters: {opentrack: {settings: {enable: 1}}}}.to_json
      }
      let(:mail)     {
        Mail.new(
          from:     Mail::Address.new('"Tester" <from@address.com>'), # Or just "Tester" <from@address.com>
          to:       "to@address.com",
          bcc:      "bcc@address.com",
          reply_to: Mail::Address.new('"Reply" <reply@address.com>'),
          subject:  "Rspec test",
          headers:  {"X-SMTPAPI" => filter}
          ) do
            text_part { body 'This is plain text' }
          end
      }
      let(:success) { SendgridApi::Result.new({message: "success"}) }

      context "valid email" do
        it "should return a successful response" do
          subject.client.should_receive(:post).with(
            "send",
            nil,
            hash_including(
              to:       ["to@address.com"],
              toname:   [nil],
              from:     "from@address.com",
              fromname: "Tester",
              bcc:      "bcc@address.com",
              subject:  "Rspec test",
              text:     kind_of(::Mail::Body),
              headers:  kind_of(String),
              "x-smtpapi".to_sym => filter
            )

          ).and_return(success)

          subject.deliver!(mail).should == success
        end

        it "should build the headers" do
          subject.client.should_receive(:post).with(
            "send",
            nil,
            hash_including(
              headers: include(
                '"Return-Path":"from@address.com"',
                '"Reply-To":"Reply <reply@address.com>"',
                '"Content-Type":"multipart/mixed"'
              )
            )

          ).and_return(success)

          subject.deliver!(mail).should == success
        end
      end

      context "multiple recipients" do
        let(:to_mail)  {
          Mail.new(
            from:     Mail::Address.new('"Tester" <from@address.com>'), # Or just "Tester" <from@address.com>
            to:       ["Tester <to@address.com>", "Another <and@address.com>"],
            subject:  "Rspec test"
          ) do
            text_part { body 'This is plain text' }
          end
        }

        it "should return a successful response" do
          subject.client.should_receive(:post).with(
            "send",
            nil,
            hash_including(
              to:       ["to@address.com", "and@address.com"],
              toname:   ["Tester", "Another"],
              from:     "from@address.com",
              fromname: "Tester",
              subject:  "Rspec test"
            )
          ).and_return(success)

          subject.deliver!(to_mail).should == success
        end

        it "should allow multiple recipients as a string" do
          subject.client.should_receive(:post).with(
            "send",
            nil,
            hash_including(
              to:       ["to@address.com", "and@address.com"]
            )
          ).and_return(success)

          to_mail.to = "to@address.com, and@address.com"
          subject.deliver!(to_mail).should == success
        end
      end

      context "invalid mail" do
        before do
          subject.client.should_receive(:post).never
        end

        it "should raise an error" do
          expect { subject.deliver!(Mail.new) }.to raise_error(ArgumentError)
        end
      end

      context "API error response" do
        let(:failure) { SendgridApi::Result.new({error: {message: "Something went wrong"}}) }

        before do
          subject.client.should_receive(:post).and_return(failure)
        end

        it "should raise an exception" do
          expect { subject.deliver!(mail) }.to raise_error(SendgridApi::Error::DeliveryError)
        end
      end
    end

    describe "#header_to_hash" do
      let(:mail)     {
        Mail.new(
          from:     Mail::Address.new('"Tester" <from@address.com>'),
          to:       "to@address.com",
          reply_to: Mail::Address.new('"Reply" <reply@address.com>'),
          subject:  "Rspec test"
        )
      }

      it "should remove values from the header" do
        hash_keys = subject.send(:header_to_hash, mail).keys
        hash_keys.should_not include("To")
        hash_keys.should_not include("From")
        hash_keys.should_not include("Subject")
        hash_keys.should     include("Reply-To")
      end
    end
  end
end