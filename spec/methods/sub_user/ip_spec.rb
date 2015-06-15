require 'spec_helper'

module SendgridApi
  describe "sub_user/ip", :vcr do
    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "user-test",
    } }

    describe ".list_ip" do
      it "should return the user ip addresses" do
        expect(subject.list_ip(user).body).to eq({success: "success", outboundcluster: "SendGrid MTA", ips: []})
      end
    end

    describe ".append_ip" do
      xit "should append the ip to the user" do
        subject.append_ip(user.merge(set: "127.0.0.1"))
      end
    end
  end
end
