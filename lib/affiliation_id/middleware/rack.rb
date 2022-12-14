# frozen_string_literal: true

require_relative '../../affiliation_id'

module AffiliationId
  module Middleware
    #
    # Rack middleware to add Affiliation ID HTTP header to rack based web frameworks
    #
    class Rack
      def initialize(app)
        @app = app
      end

      def call(env)
        AffiliationId.current_id = header_from_env(env) || AffiliationId.renew_current_id!

        @app.call(env).tap { |_status, headers, _body| headers[config.header_name] = AffiliationId.current_id }
      ensure
        AffiliationId.reset!
      end

      private

      def header_from_env(env)
        value = env["HTTP_#{config.header_name.upcase.tr('-', '_')}"]

        value&.gsub(/[^\w\-@.]/, '')&.[](0...255)
      end

      def config
        AffiliationId.configuration
      end
    end
  end
end
