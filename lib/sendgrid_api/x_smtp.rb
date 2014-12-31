require "json"

module SendgridApi
  class XSmtp
    include Comparable

    attr_reader :xsmtp

    def initialize(hash={})
      hash = JSON.parse(hash) if hash.is_a?(String)
      @xsmtp = hash
      yield self if block_given?
    end

    def []=(key, value)
      @xsmtp[key.to_sym] = value
    end

    def [](key)
      @xsmtp[key.to_sym]
    end

    # Set Sendgrid unique args (and stringifys the keys)
    # @param [Hash] { message_status_id: email_message.message_status.id.to_s }
    #
    def unique_args(attrs)
      @xsmtp[:unique_args] ||= {}
      @xsmtp[:unique_args].merge!(attrs.inject({}){ |memo, (k, v)| memo[k.to_sym] = v; memo })
    end

    # Set Sendgrid bcc
    # @param [String] email
    #
    def bcc(email)
      filters({bcc: {settings: {email: email}}})
    end

    # Add a spam check application
    # @param [Float] max_score
    # @param [String] callback url
    #
    def spamcheck(url, max_score=5.0)
      filters(spamcheck: {settings: {enable: 1, maxscore: max_score, url: url}})
    end

    # Set Sendgrid applications/filters
    # Takes either the filter name and enables, or a raw hash
    # @param [Symbol,String,Hash]
    #
    def filters(app)
      @xsmtp[:filters] ||= {}
      app = {app.to_sym => {settings: {enable: 1}}} if !app.is_a?(Hash)
      # TODO: Validate Hash syntax
      @xsmtp[:filters].merge!(app)
    end

    # Set Sendgrid category
    # @param [String,Array]
    #
    def category(name)
      @xsmtp.merge!(category: Array(name))
    end

    def to_s
      self.to_json
    end

    def to_json
      raise Error::OptionsError("Invalid X-SMTPAPI header options") unless validate_options
      @xsmtp.to_json
    end

    def <=>(other)
      @xsmtp <=> other
    end

    def empty?
      @xsmtp.to_s == "{}"
    end

    private

    # TODO: Validate header and options
    def validate_options
      true
    end
  end
end
