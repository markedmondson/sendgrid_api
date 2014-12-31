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
        subject.client.should_not be_nil
      end

      it "should use the Client passed" do
        sub_user = SubUser.new(client, config)
        sub_user.client.should eq(client)
      end

      it "should set the method" do
        subject.options[:method].should == "customer"
      end
    end

    describe ".list", :vcr do
      it "should return the list of sub users" do
        subject.list({username: "user-test"}).response.should == [{
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

    describe ".create", :vcr do
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
        result.error?.should == true
        result.message.should include("Username is required")
      end

      it "should create a new user" do
        subject.create(params).success?.should == true
      end
    end

    describe ".update", :vcr do
      let(:params) { {
        user:       "user-test",
        first_name: "updated"
      } }

      it "should update the user" do
        subject.update(params).success?.should == true
      end

      it "should update the email address if passed" do
        params = {
          user:     "user-test",
          email:    "new@address.com"
        }

        subject.should_receive(:update_email).once.and_call_original

        subject.update(params).success?.should == true
      end
    end

    describe ".update_email", :vcr do
      let(:params) { {
        user:       "user-test",
        email:      "new@address.com"
      } }

      it "should update the user email" do
        subject.update_email(params).success?.should == true
      end
    end

    describe ".password", :vcr do
      let(:params) { {
        user:             "user-test",
        password:         "updated",
        confirm_password: "updated"
      } }

      it "should update the user" do
        subject.password(params).success?.should == true
      end
    end

    describe ".enable", :vcr do
      it "should update the user" do
        subject.enable(user).success?.should == true
      end
    end

    describe ".disable", :vcr do
      it "should update the user" do
        subject.disable(user).success?.should == true
      end
    end
  end
end
