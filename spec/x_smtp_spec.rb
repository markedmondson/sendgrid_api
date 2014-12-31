require 'spec_helper'

module SendgridApi
  describe "x_smtp" do
    let(:xsmtp) { XSmtp.new }

    describe ".initialize" do
      let(:args) { {unique_args: { something: 1}} }
      it "should initialize with a hash if sent" do
        XSmtp.new(args).should == args
      end
    end

    describe ".spamcheck" do
      it "should add a spamcheck filter" do
        xsmtp.spamcheck("http://www.google.com", 10)
        xsmtp.should == { filters: { spamcheck: { settings: { enable: 1, url: "http://www.google.com", maxscore: 10 }}}}
      end
    end
  end
end
