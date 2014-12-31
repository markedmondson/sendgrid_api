module SendgridApi
  class Method
    extend Forwardable
    attr_accessor :method, :client, :options

    def initialize(client=nil, options={})
      @options ||= options
      @options.merge!(method: method)
      @client = set_method(client) || initialize_client
    end

    def_delegator :@client, :get
    def_delegator :@client, :post

    # Delegate to a SendgridApi::Client
    #
    # @return [SendgridApi::Client]
    #
    def initialize_client
      @client = SendgridApi::Client.new(@options) unless defined?(@client) && @client.hash == @options.hash
      @client
    end

    # Has a client been initialized?
    #
    # @return [Boolean]
    #
    def client?
      !!@client
    end

    private

    # If we're providing the client, the endpoint may need to be reset set
    # @param [Client]
    # @return [Client]
    #
    def set_endpoint(endpoint)
      @client.instance_variable_set("@endpoint", endpoint)
    end

    # If we're providing the client, the method needs to be set
    # @param [Client]
    # @return [Client]
    #
    def set_method(client)
      client.tap{|c| c.method = method } if client
    end

    # Are all the required params here?
    # @param [Hash]
    # @param [Array<Symbol>]
    # @return [Boolean]
    #
    def validate_options(options, attrs)
      matched_attrs = options.keys & attrs
      if matched_attrs.to_set != attrs.to_set
        raise SendgridApi::Error::OptionsError.new("#{(attrs - matched_attrs).join(", ")} required options are missing")
      end
    end

    # Get the method name (demodulize and underscore)
    # @return [String]
    #
    def method
      @method ||= self.class.to_s.split("::").last.
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
