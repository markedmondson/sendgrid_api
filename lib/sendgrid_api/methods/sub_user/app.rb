module SendgridApi
  module Customer
    module App
      def self.included(base)
        # Get Apps
        #
        def list_apps(options = {})
          validate_options(options, [:user])
          get("apps", "getavailable", options)
        end

        # Activate App
        #
        def activate_app(options = {})
          validate_options(options, [:user, :name])
          get("apps", "activate", options)
        end

        # Get app settings
        #
        def app_settings(options = {})
          validate_options(options, [:user, :name])
          get("apps", "getsettings", options)
        end

        def setup_domainkeys_app(options = {})
          validate_options(options, [:domain, :sender])
          setup_app({name: "domainkeys", enable: true}.merge(options))
        end

        def setup_dkim_app(options = {})
          validate_options(options, [:domain, :use_from])
          setup_app({name: "dkim", enable: true}.merge(options))
        end

        def setup_addresswhitelist_app(options = {})
          validate_options(options, [:list])
          setup_app({name: "addresswhitelist", enable: true}.merge(options))
        end

        def setup_eventnotify(options = {})
          # Setup defaults and merge
          options = {
            processed: 1,
            dropped: 1,
            deferred: 0,
            delivered: 1,
            bounce: 1,
            click: 1,
            open: 1,
            unsubscribe: 0,
            subscribe: 0,
            spamreport: 1,
            batch: 1,
            version: 3
          }.merge(options)
          validate_options(options, [:url])
          setup_app({name: "eventnotify", enable: true}.merge(options))
        end

        def setup_newrelic(options = {})
          validate_options(options, [:license_key])
          setup_app({name: "newrelic", enable: true}.merge(options))
        end

        def setup_clicktrack(options = {})
          options = {
            enable_text: 1
          }.merge(options)
          setup_app({name: "clicktrack", enable: true}.merge(options))
        end

        private

        # Setup App
        #
        def setup_app(options = {})
          validate_options(options, [:user, :name])
          activate_app(options.select{ |k, v| [:user, :name].include? k }) if options[:enable] == true
          post("apps", "setup", options.reject{ |k, v| k == :enable })
        end
      end
    end
  end
end
