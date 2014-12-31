module SendgridApi
  class Result
    attr_reader :response

    # Initialize a new Response, throw exception for fatal errors
    # @param [Hash] result
    #
    def initialize(response)
      @response = response
    end

    # Was it successful?
    # @return [Boolean]
    #
    def success?
      !error?
    end

    # Was there an error?
    # @return [Boolean]
    #
    def error?
      @response.is_a?(Hash) ? @response.has_key?(:error) || @response.has_key?(:errors) : false
    end

    def errors
      message if error?
    end

    # Sometimes there's an error code
    def code
      @response.fetch(:error, {}).fetch(:code, nil) if @response.is_a?(Hash) && error?
    end

    # Return the message from the response
    # @return [String]
    #
    def message
      @response.fetch(:error, {}).fetch(:message, nil) || @response.fetch(:errors, nil) || @response.fetch(:message, nil) if @response.is_a?(Hash)
    end
  end
end
