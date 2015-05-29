require 'faraday'
require 'faraday/request/multipart'
require 'sendgrid_api/configurable'
require 'sendgrid_api/response/parse_json'
require 'sendgrid_api/response/parse_xml'
require 'sendgrid_api/version'

module SendgridApi
  module Default
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

      def connection_options
        {
          headers: {
            accept: 'application/#{format}',
            accept_charset: 'utf-8',
            user_agent: "SendgridApi Ruby Gem v#{SendgridApi::VERSION}"
          },
          request: {
            open_timeout: 5,
            timeout: 10
          }
        }
      end

      # @return [String]
      def endpoint
        @endpoint ||= 'https://sendgrid.com/apiv2'
      end

      # @note Faraday's middleware stack implementation is comparable to that of Rack middleware.  The order of middleware is important: the first middleware on the list wraps all others, while the last middleware is the innermost one.
      # @see https://github.com/technoweenie/faraday#advanced-middleware-usage
      # @see http://mislav.uniqpath.com/2011/07/faraday-advanced-http/
      # @return [Faraday::Builder]
      def middleware
        @middleware ||= proc do |builder|
          # Encode request params as "www-form-urlencoded"
          builder.use Faraday::Request::UrlEncoded

          builder.response :sendgrid_api_parse_json#, content_type: /\bjson$/
          # builder.response SendgridApi::Response::ParseXml#, content_type: /\bxml$/
          builder.response Faraday::Response::Logger if ENV['DEBUG']

          # Set Faraday's HTTP adapter
          builder.adapter Faraday.default_adapter
        end
      end

    end
  end
end
