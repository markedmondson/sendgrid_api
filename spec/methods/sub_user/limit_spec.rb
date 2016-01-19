require 'spec_helper'

module SendgridApi
  describe "sub_user/limit", vcr: true do
    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "user-test",
    } }

    describe ".get_limit" do
      it "should return the send limit" do
        expect(subject.get_limit(user).body).to eq [{credit: "0", credit_remain: "500", last_reset: "2013-10-31"}]
      end

      it "should return an error if the user doesn't exist" do
        expect { subject.get_limit({user: "user-missing"}) }.to raise_error SendgridApi::Error::ClientError
      end
    end

    describe ".remove_limit" do
      it "should remove the send limit" do
        expect(subject.remove_limit(user).success?).to eq true
      end
    end

    describe ".set_limit" do
      it "should set the send limit" do
        expect(subject.set_limit(user.merge(credits: 500)).success?).to eq true
      end
    end
  end
end
