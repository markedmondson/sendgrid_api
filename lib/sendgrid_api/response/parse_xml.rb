require 'faraday_middleware'
require 'multi_xml'

module SendgridApi
  module Response
    class ParseXml < ::Faraday::Response::Middleware
    end
  end
end
