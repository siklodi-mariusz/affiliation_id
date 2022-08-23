# frozen_string_literal: true

require_relative '../../affiliation_id'

module AffiliationId
  module Middleware
    class Rails # :nodoc:
      def initialize(app)
        @app = app
      end

      def call(env)
        req = ActionDispatch::Request.new env
        AffiliationId.current_id = req.request_id
        @app.call(env)
      end
    end
  end
end
