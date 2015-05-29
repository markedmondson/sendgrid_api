require 'faraday'
require 'json'

module SendgridApi
  class Client
    include SendgridApi::Configurable

    attr_reader :action, :format, :logger
    attr_accessor :method

    # Initializes a new Client object
    #
    # @param options [Hash]
    # @return [SendgridApi::Client]
    #
    def initialize(options={})
      @logger = options.delete(:logger) || self.class.logger
      SendgridApi::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || SendgridApi.instance_variable_get(:"@#{key}"))
      end
      @method ||= options[:method]
    end

    # Perform an HTTP GET request
    #
    def get(action, task, params={})
      @action = action
      @task = task
      request(:get, params)
    end

    # Perform an HTTP POST request
    #
    def post(action, task=nil, params={})
      @action = action
      @task = task
      request(:post, params)
    end

    private

    def self.logger
      Log4r::Logger.new("sendgrid_api::client")
    end

    # @return [Boolean]
    #
    def path_params?
      path_params.values.all?
    end

    # @return [Boolean]
    #
    def authentication_params?
      @api_user && @api_key && !@api_user.empty? && !@api_key.empty?
    end

    # @return [Hash]
    #
    def path_params
      {
        method: @method,
        action: @action,
        format: @format
      }
    end

    # Returns a path for the API call
    # @return [String]
    #
    def path_setup
      raise ArgumentError, "Required path param missing" unless path_params?
      path_params.values.join(".")
    end

    # Add hash of authentication params
    # @return [Hash]
    #
    def authentication_params
      {
        api_user: @api_user,
        api_key:  @api_key
      }
    end

    # Format the final request params
    # @param [Hash]
    # @return [Hash]
    #
    def request_params(params)
      raise ArgumentError, "Required authentication params missing" unless authentication_params?
      params.merge!(authentication_params)
      params.merge!(task: @task) if @task
      params
    end

    def request(method, params={})
      response = connection.send(method.to_sym, path_setup, request_params(params))
      Result.new(response.body) #.force_encoding('utf-8')
    rescue SendgridApi::Error::ParserError => e
      @logger.error "Unable to parse Sendgrid API response: #{e.message}"
      @logger.debug response
      raise e
    end

    # Returns a Faraday::Connection object
    #
    # @return [Faraday::Connection]
    #
    def connection
      @connection ||= Faraday.new(@endpoint, @connection_options, &@middleware)
    end
  end
end
