require 'spec_helper'

module SendgridApi
  describe "sub_user" do
    subject(:sub_user) { SubUser.new(nil, config) }
    let(:user) { {
      user: "user-test",
    } }

    describe ".initialize" do
      let(:client)     { Client.new(config) }

      it "should create a Client instance" do
        expect(subject.client).to_not be_nil
      end

      it "should use the Client passed" do
        sub_user = SubUser.new(client, config)
        expect(sub_user.client).to eq client
      end

      it "should set the method" do
        expect(subject.options[:method]).to eq "customer"
      end
    end

    describe ".list", vcr: true do
      it "should return the list of sub users" do
        body = subject.list({username: "user-test"}).body

        expect(body).to eq [{
          username:         "user-test",
          email:            "test@address.com",
          active:           "true",
          first_name:       "first",
          last_name:        "last",
          address:          "address",
          address2:         "",
          city:             "city",
          state:            "state",
          zip:              "zip",
          country:          "xx",
          phone:            "phone",
          website:          "http://www.website.com",
          website_access:   "true"
        }]
      end
    end

    describe ".create", vcr: true do
      let(:params) { {
        username:         "user-test",
        email:            "test@address.com",
        company:          "company",
        first_name:       "first",
        last_name:        "last",
        address:          "address",
        address2:         "",
        city:             "city",
        state:            "state",
        zip:              "zip",
        country:          "xx",
        phone:            "phone",
        website:          "http://www.website.com",
        password:         "password",
        confirm_password: "password"
      } }

      it "should throw an error when there are missing params" do
        expect { subject.create }.to raise_error Error::OptionsError
      end

      it "should return an error if a parameter is invalid" do
        result = subject.create(params.merge({username: ""}))
        expect(result.error?).to eq true
        expect(result.message).to include("Username is required")
      end

      it "should create a new user" do
        expect(subject.create(params).success?).to eq true
      end
    end

    describe ".update", vcr: true do
      let(:params) { {
        user:       "user-test",
        first_name: "updated"
      } }

      it "should update the user" do
        expect(subject.update(params).success?).to eq true
      end

      it "should update the email address if passed" do
        params = {
          user:     "user-test",
          email:    "new@address.com"
        }

        expect(subject).to receive(:update_email).once.and_call_original

        expect(subject.update(params).success?).to eq true
      end
    end

    describe ".update_email", vcr: true do
      let(:params) { {
        user:       "user-test",
        email:      "new@address.com"
      } }

      it "should update the user email" do
        expect(subject.update_email(params).success?).to eq true
      end
    end

    describe ".password", vcr: true do
      let(:params) { {
        user:             "user-test",
        password:         "updated",
        confirm_password: "updated"
      } }

      it "should update the user" do
        expect(subject.password(params).success?).to eq true
      end
    end

    describe ".enable", vcr: true do
      it "should update the user" do
        expect(subject.enable(user).success?).to eq true
      end
    end

    describe ".disable", vcr: true do
      it "should update the user" do
        expect(subject.disable(user).success?).to eq true
      end
    end

    describe ".setup_whitelabel", vcr: true do
      it "should update the subuser whitelabel domain" do
        expect(subject.setup_whitelabel(user.merge(mail_domain: "email.test.net")).success?).to eq true
      end

      context "for a missing whitelabel domain" do
        it "should return an error" do
          expect(subject.setup_whitelabel(user.merge(mail_domain: "missing.test.net")).message).to include "Whitelabel record not found"
        end
      end
    end
  end
end
