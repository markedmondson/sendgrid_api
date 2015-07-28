require 'spec_helper'

module SendgridApi
  describe "sub_user/invalid_email", :vcr do
    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "api-test",
    } }

    describe ".list_invalid_emails" do
      it "should return the user invalid email addresses" do
        expect(subject.list_invalid_emails(user).body).to eq([{email: "test@test.com", reason: "Known bad domain"}])
      end
    end

    describe ".delete_invalid_email" do
      it "should delete the invalid email address" do
        result = subject.delete_invalid_email(user.merge(email: "test@test.com"))
        expect(result.message).to eq "success"
      end
    end
  end
end
