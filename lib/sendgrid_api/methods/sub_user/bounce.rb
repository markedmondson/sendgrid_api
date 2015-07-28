module SendgridApi
  module User
    module Bounce
      def self.included(base)

        def initialize(client=nil, options={})
          @method = "user"
          super
        end

        # Get bounce list
        #
        def list_bounces(options = {})
          validate_options(options, [:user])
          get("bounces", "get", options)
        end

        # Delete bounce
        #
        def delete_bounce(options = {})
          validate_options(options, [:user, :email])
          post("bounces", "delete", options)
        end
      end
    end
  end
end
