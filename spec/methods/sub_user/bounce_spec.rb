require 'spec_helper'

module SendgridApi
  describe "sub_user/bounce", vcr: true do
    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "api-test",
    } }

    describe ".list_bounces" do
      it "should return the user bounced addresses" do
        expect(subject.list_bounces(user).body).to eq([{email: "test@test.com", status: "5.5.0", reason: "550 User unknown"}])
      end
    end

    describe ".delete_bounce" do
      it "should delete the bounced address" do
        result = subject.delete_bounce(user.merge(email: "test@test.com"))
        expect(result.message).to eq "success"
      end
    end
  end
end
