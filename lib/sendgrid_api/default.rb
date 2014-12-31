require 'faraday'
require 'faraday/request/multipart'
require 'sendgrid_api/configurable'
require 'sendgrid_api/response/parse_json'
require 'sendgrid_api/response/parse_xml'
require 'sendgrid_api/version'

module SendgridApi
  module Default
#     Faraday.default_adapter = :net_http_persistent

    ENDPOINT = 'https://sendgrid.com/apiv2'
    MIDDLEWARE = Faraday::Builder.new do |builder|
      # Encode request params as "www-form-urlencoded"
      builder.use Faraday::Request::UrlEncoded
      # Parse JSON response bodies
      builder.use SendgridApi::Response::ParseJson#, content_type: /\bjson$/
      # Parse XML response bodies
      builder.use SendgridApi::Response::ParseXml#, content_type: /\bxml$/
      # Use Faraday logger
      builder.use Faraday::Response::Logger if ENV['DEBUG']
      # Set Faraday's HTTP adapter
      builder.adapter Faraday.default_adapter
    end

    class << self

      # @return [Hash]
      def options
        Hash[SendgridApi::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # @return [String]
      def api_user
        ENV['DEFAULT_SENDGRID_API_USER']
      end

      # @return [String]
      def api_key
        ENV['DEFAULT_SENDGRID_API_KEY']
      end

      # @return [Symbol]
      def format
        :json
      end

      # @return [String]
      def endpoint
        ENDPOINT
      end

      # @note Faraday's middleware stack implementation is comparable to that of Rack middleware.  The order of middleware is important: the first middleware on the list wraps all others, while the last middleware is the innermost one.
      # @see https://github.com/technoweenie/faraday#advanced-middleware-usage
      # @see http://mislav.uniqpath.com/2011/07/faraday-advanced-http/
      # @return [Faraday::Builder]
      def middleware
        MIDDLEWARE
      end

    end
  end
end
