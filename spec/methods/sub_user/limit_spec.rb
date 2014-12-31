require 'spec_helper'

module SendgridApi
  describe "sub_user/limit", :vcr do
    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "user-test",
    } }

    describe ".get_limit" do
      it "should return the send limit" do
        subject.get_limit(user).response.should == [{credit: "0", credit_remain: "500", last_reset: "2013-10-31"}]
      end

      it "should return an error if the user doesn't exist" do
        subject.get_limit({user: "user-missing"}).success?.should == false
      end
    end

    describe ".remove_limit" do
      it "should remove the send limit" do
        subject.remove_limit(user).success?.should == true
      end
    end

    describe ".set_limit" do
      it "should set the send limit" do
        subject.set_limit(user.merge(credits: 500)).success?.should == true
      end
    end
  end
end
