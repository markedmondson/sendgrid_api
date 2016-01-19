require 'spec_helper'

module SendgridApi
  describe "sub_user/app", vcr: true do
    matcher :include_app do |name, active=true|
      match do |actual|
        actual.any? { |a| a[:name] == name && a[:activated] == active }
      end
    end

    subject(:sub_user) { SendgridApi::SubUser.new(nil, config) }
    let(:user) { {
      user: "user-test",
    } }

    describe ".list_apps" do
      it "should return the available apps" do
        expect(subject.list_apps(user).body).to include_app("domainkeys", false)
      end
    end

    describe ".activate_app" do
      it "should activate an app for the user" do
        expect(subject.activate_app(user.merge(name: "domainkeys")).body).to eq({message: "success"})
      end
    end

    describe ".setup_domainkeys_app" do
      let(:settings) { { domain: "test.com", sender: 1 } }
      let(:params)   { user.merge(settings) }

      it "should setup the domainkeys app" do
        expect(subject.setup_domainkeys_app(params).body).to eq({message: "success"})
        expect(subject.app_settings(user.merge(name: "domainkeys")).body).to eq({ settings: settings })
      end

      it "should enable the app by default" do
        expect(subject).to receive(:activate_app)
        expect(subject.setup_domainkeys_app(params).body).to eq({message: "success"})
        expect(subject.list_apps(user).body).to include_app("domainkeys", true)
      end

      it "can setup the app and not enable it" do
        expect(subject).not_to receive(:activate_app)
        expect(subject.setup_domainkeys_app(params.merge(enable: false)).body).to eq({message: "success"})
        expect(subject.list_apps(user).body).to include_app("domainkeys", false)
      end
    end

    describe ".setup_addresswhitelist_app" do
      let(:settings) { { list: ["email@test.com"] } }
      let(:params)   { user.merge(settings) }

      it "should setup the address whitelist app" do
        expect(subject.setup_addresswhitelist_app(params).body).to eq({message: "success"})
        expect(subject.app_settings(user.merge(name: "addresswhitelist")).body).to eq({settings: settings})
      end
    end

    describe ".setup_eventnotify" do
      let(:settings) { { url: "http//www.google.com" } }
      let(:params)   { user.merge(settings) }

      it "should setup the eventnotify app with default settings" do
        expect(subject).to receive(:setup_app).with(
          hash_including(
            user:        "user-test",
            url:         "http//www.google.com",
            processed:   1,
            dropped:     1,
            deferred:    0,
            batch:       1,
            version:     3
          )
        )

        subject.setup_eventnotify(params)
      end
    end

    describe ".setup_clicktrack" do
      it "should setup the clicktrack app with default settings" do
        expect(subject).to receive(:setup_app).with(
          hash_including(
            user:        "user-test",
            enable_text: 1
          )
        )

        subject.setup_clicktrack(user)
      end
    end
  end
end
