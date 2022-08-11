# frozen_string_literal: true

require 'faraday'

require_relative '../../affiliation_id'

module AffiliationId
  module Middleware
    #
    # Faraday::Middleware for handling requests made with Faraday with affiliation_id
    #
    # Usage:
    #   conn = Faraday.new do |f|
    #     f.request :affiliation_id # include AffiliationID.current_id in the request headers
    #     f.adapter :net_http # Use the Net::HTTP adapter
    #    end
    #
    class Faraday < ::Faraday::Middleware
      def on_request(env)
        return if env[:request_headers][AffiliationId::HEADER_KEY]

        env[:request_headers][AffiliationId::HEADER_KEY] = AffiliationId.current_id
      end
    end
  end
end

if Faraday::Request.respond_to? :register_middleware
  Faraday::Request.register_middleware affiliation_id: AffiliationId::Middleware::Faraday
end
