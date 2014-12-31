module SendgridApi
  module Customer
    module Ip
      def self.included(base)
        # Get IP limit
        #
        def list_ip(options = {})
          validate_options(options, [:user])
          get("sendip", "list", options)
        end

        # Append IP
        #
        def append_ip(options = {})
          validate_options(options, [:user, :set])
          post("sendip", "append", options)
        end
      end
    end
  end
end
