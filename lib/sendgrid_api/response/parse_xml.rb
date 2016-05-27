require 'faraday_middleware'

module SendgridApi
  module Response
    class ParseXml < ::Faraday::Response::Middleware
    end
  end
end
