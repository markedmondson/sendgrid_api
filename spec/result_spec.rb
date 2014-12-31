require 'spec_helper'

module SendgridApi
  describe "result" do
    describe ".success?" do
      it "should return true for a successful response" do
        Result.new({message: "success"}).success?.should == true
      end

      it "should return false for an unsuccessful response" do
        Result.new({message: "error", error: "Error"}).success?.should == false
      end
    end

    describe ".message" do
      it "should return the error message for a failed response" do
        Result.new({message: "error", errors: "Oops"}).message.should == "Oops"
      end
    end
  end
end
