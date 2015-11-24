module SendgridApi
  module User
    module Bounce
      def self.included(base)
        # Get bounce list
        #
        def list_bounces(options = {})
          client_settings
          validate_options(options, [:user])
          get("bounces", "get", options)
        end

        # Delete bounce
        #
        def delete_bounce(options = {})
          client_settings
          validate_options(options, [:user, :email])
          post("bounces", "delete", options)
        end

        private

        def client_settings
          client.v1!.method = "user"
        end
      end
    end
  end
end
