# frozen_string_literal: true

require_relative 'middleware/rails'

module AffiliationId
  class Railtie < ::Rails::Railtie # :nodoc:
    initializer 'affiliation_id.initializer' do |app|
      app.middleware.insert_after ActionDispatch::RequestId, AffiliationId::Middleware::Rails
    end

    config.to_prepare do
      AffiliationId.reset!
    end
  end
end
