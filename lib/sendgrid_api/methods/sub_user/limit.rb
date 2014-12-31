module SendgridApi
  module Customer
    module Limit
      def self.included(base)
        # Get send limit
        #
        def get_limit(options = {})
          validate_options(options, [:user])
          get("limit", "retrieve", options)
        end

        # Remove send limit
        #
        def remove_limit(options = {})
          validate_options(options, [:user])
          post("limit", "none", options)
        end

        # Set send limit
        #
        def set_limit(options = {})
          validate_options(options, [:user, :credits])
          post("limit", "total", options)
        end
      end
    end
  end
end
