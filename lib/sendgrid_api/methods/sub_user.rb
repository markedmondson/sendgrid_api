require 'sendgrid_api/method'
require 'sendgrid_api/methods/sub_user/app'
require 'sendgrid_api/methods/sub_user/bounce'
require 'sendgrid_api/methods/sub_user/limit'
require 'sendgrid_api/methods/sub_user/ip'
require 'sendgrid_api/methods/sub_user/spam_report'

module SendgridApi
  class SubUser < SendgridApi::Method
    include Customer::App
    include Customer::Limit
    include Customer::Ip

    include User::Bounce
    include User::SpamReport

    def initialize(client=nil, options={})
      @method = "customer"
      super
    end

    # List all subusers
    #
    def list(options = {})
      get("profile", "get", options)
    end

    # Create a subuser
    #
    def create(options = {})
      validate_options(options, [
        :username,
        :password,
        :confirm_password,
        :email,
        :first_name,
        :last_name,
        :address,
        :city,
        :state,
        :zip,
        :country,
        :phone,
        :website,
        :company
      ])
      post("add", nil, options)
    end

    # Update a subuser
    #
    def update(options = {})
      validate_options(options, [:user])
      result = get("profile", "set", options)
      # Call update email if it was passed in the params
      email_options = options.select { |k,v| [:user, :email].include?(k) }
      result.success? && options.include?(:email) ? update_email(email_options) : result
    end

    # Update a subuser username
    #
    def update_username(options = {})
      validate_options(options, [:user, :username])
      get("profile", "setUsername", options)
    end

    # Update a subuser email
    #
    def update_email(options = {})
      validate_options(options, [:user, :email])
      get("profile", "setEmail", options)
    end

    # Update a password
    #
    def password(options = {})
      validate_options(options, [:user, :password, :confirm_password])
      post("password", nil, options)
    end

    # Enable a subuser
    #
    def enable(options = {})
      access("enable", options)
    end

    # Disable a subuser
    #
    def disable(options = {})
      access("disable", options)
    end

    # Enable website access to subuser
    #
    def website_enable(options = {})
      access("website_enable", options)
    end

    # Disable website access to subuser
    #
    def website_disable(options = {})
      access("website_disable", options)
    end

    private

    def access(action, options = {})
      validate_options(options, [:user])
      post(action, nil, options)
    end

    def user(action, options = {})
      validate_options(options, [
        :username,
        :password,
        :confirm_password,
        :email,
        :first_name,
        :last_name,
        :address,
        :city,
        :state,
        :zip,
        :country,
        :phone,
        :website,
        :company
      ])
      post(action, options)
    end
  end
end
