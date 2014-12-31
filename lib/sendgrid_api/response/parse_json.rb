require 'faraday_middleware'
require 'json/ext'

module SendgridApi
  module Response
    class ParseJson < ::FaradayMiddleware::ParseJson
      def on_complete(env)
        status = env[:status]
        # Sometimes SendGrid puts a "response code" in the message body, seems to be 4XX only
        if (env[:body].is_a?(Hash))
          error = env[:body].fetch(:error, {})
          error_code = error.fetch(:code, nil)
          error_message = error.fetch(:message, "Unknown SendgridApi error")
        end
        if status == 403 || status == 401 || error_code == 403 || error_code == 401
          raise Error::AuthenticationError.new(error_message)
        elsif status =~ /^5/
          raise Error::ApiException.new("SendgridApi call unsuccessful. Try again later.")
        end
      end

      def call(env)
        @app.call(env).on_complete do |environment|
          env[:body] = parse(env[:body])
          on_complete(environment)
        end
      end

      private

      def parse(body)
        JSON.parse(body, symbolize_names: true)
      end
    end
  end
end
