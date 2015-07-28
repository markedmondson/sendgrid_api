require 'spec_helper'

module SendgridApi
  describe "sub_user/spam_report", :vcr do
    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "api-test",
    } }

    describe ".list_spam_reports" do
      it "should return the user spam report addresses" do
        expect(subject.list_spam_reports(user).body).to eq([{email: "test@test.com"}])
      end
    end

    describe ".delete_spam_report" do
      it "should delete the spam report address" do
        result = subject.delete_spam_report(user.merge(email: "test@test.com"))
        expect(result.message).to eq "success"
      end
    end
  end
end
