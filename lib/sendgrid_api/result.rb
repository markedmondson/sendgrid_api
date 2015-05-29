module SendgridApi
  class Result
    attr_reader :body

    # Initialize a new Result using the response body
    # @param [Hash,Array] response body
    #
    def initialize(body)
      @body = body
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
      body_error?
    end

    # Sometimes there's an error code
    # @return [String]
    #
    def code
      body_error.fetch(:code, nil) if error?
    end

    # Return the message from the response
    # @return [String]
    #
    def message
      (body_error.fetch(:message, nil) || body.fetch(:errors, nil) || body.fetch(:message, nil)) if body.is_a?(Hash)
    end

    private

    def body_error?
      (body.has_key?(:error) || body.has_key?(:errors)) if body.is_a?(Hash)
    end

    def body_error
      body.fetch(:error, {}) if body.is_a?(Hash)
    end
  end
end
