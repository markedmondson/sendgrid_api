require 'sendgrid_api/method'

module SendgridApi
  class Mail < SendgridApi::Method
    extend Forwardable

    attr_reader :xsmtp

    # @param [Client]
    # @param [Hash] options
    #
    def initialize(client=nil, options={})
      @xsmtp ||= XSmtp.new(options[:xsmtp] || {})
      # @xsmtp.unique_args(transport: "api")
      super
      set_endpoint("https://sendgrid.com/api/")
    end

    # Send mail
    # @param [Hash] options
    #
    def queue(options = {})
      validate_options(options, [:to, :from, :subject, :text, :html])
      options.reject!{ |k, v| v.blank? }
      options.merge!(x_smtpapi) unless @xsmtp.empty?
      post("send", nil, options)
    end

    def_delegators :@xsmtp, :unique_args, :filters, :category

    # Set Sendgrid bcc
    # @param [String] email
    #
    def bcc(email)
      filters({bcc: {settings: {email: email}}})
    end

    # Format X-SMTP options
    # @return [Hash]
    #
    def x_smtpapi
      {"x-smtpapi".to_sym => @xsmtp.to_s}
    end
  end
end
