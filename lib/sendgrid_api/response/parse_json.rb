require 'faraday_middleware'
require 'json/ext'

module SendgridApi
  module Response
    class ParseJson < ::FaradayMiddleware::ParseJson
      # @return [Faraday::Response]
      def call(env)
        response = @app.call(env)

        content_type = response.headers['content-type']
        if content_type == "application/json" && !response.env[:body].strip.empty?
          response.env[:body] = parse_body(response.env[:body])

          # Sometimes SendGrid puts a "status code" in the message body
          # push this onto the response if it exists
          if response.body.is_a?(Hash) && (error = response.body.fetch(:error, {}))
            response.env[:status] = error.fetch(:code, nil).to_i
            @message = error.fetch(:message, nil)
          end
        end
        process_status(response, @message)

        response
      end

      private

      def process_status(response, message="Unknown SendgridApi error")
        status = response.status
        if status == 403 || status == 401
          raise SendgridApi::Error::AuthenticationError.new(message)
        elsif status >= 500 && status < 600
          raise SendgridApi::Error::ApiException.new("SendgridApi call unsuccessful. Try again later.")
        end
      end

      def parse_body(body)
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError => e
        raise SendgridApi::Error::ParserError.new e.message
      end
    end
  end
end
