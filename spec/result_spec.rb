require 'spec_helper'

module SendgridApi
  describe "result" do
    let(:error_json)   { {error: {message: "Message", code: 401}} }

    describe ".success?" do
      it "should return true for a successful response" do
        expect(Result.new({message: "success"}).success?).to eq(true)
      end

      it "should return false for an unsuccessful response" do
        expect(Result.new(error_json).success?).to eq(false)
      end
    end

    describe ".message" do
      it "should return the error message for a failed response" do
        expect(Result.new(error_json).message).to eq("Message")
      end
    end
  end
end
