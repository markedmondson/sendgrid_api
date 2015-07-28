module SendgridApi
  module Customer
    module InvalidEmail
      def self.included(base)
        # Get invalid emails list
        #
        def list_invalid_emails(options = {})
          validate_options(options, [:user])
          get("invalidemails", "get", options)
        end

        # Delete invalid emails
        #
        def delete_invalid_email(options = {})
          validate_options(options, [:user, :email])
          post("invalidemails", "delete", options)
        end
      end
    end
  end
end
