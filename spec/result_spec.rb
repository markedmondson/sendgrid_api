require 'spec_helper'

module SendgridApi
  describe "result" do
    let(:error_json)   { {error: {message: "Message", code: 401}} }

    describe ".success?" do
      it "should return true for a successful response" do
        Result.new({message: "success"}).success?.should == true
      end

      it "should return false for an unsuccessful response" do
        Result.new(error_json).success?.should == false
      end
    end

    describe ".message" do
      it "should return the error message for a failed response" do
        Result.new(error_json).message.should == "Message"
      end
    end
  end
end
