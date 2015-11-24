module SendgridApi
  module User
    module SpamReport
      def self.included(base)
        # Get spam report list
        #
        def list_spam_reports(options = {})
          client_settings
          validate_options(options, [:user])
          get("spamreports", "get", options)
        end

        # Delete spam report
        #
        def delete_spam_report(options = {})
          client_settings
          validate_options(options, [:user, :email])
          post("spamreports", "delete", options)
        end

        private

        def client_settings
          client.v1!.method = "user"
        end
      end
    end
  end
end
