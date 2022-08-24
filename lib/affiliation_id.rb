# frozen_string_literal: true

require 'securerandom'

require_relative 'affiliation_id/version'
require_relative 'affiliation_id/configuration'
require_relative 'affiliation_id/middleware/faraday'
require_relative 'affiliation_id/middleware/sidekiq_client'
require_relative 'affiliation_id/middleware/sidekiq_server'
require_relative 'affiliation_id/railtie' if defined?(Rails::Railtie)

module AffiliationId # :nodoc:
  THREAD_KEY      = 'AFFILIATION_ID'
  SIDEKIQ_JOB_KEY = 'affiliation_id'

  class << self
    attr_writer :configuration

    #
    # Returns the current Affiliation ID
    #
    # @return [String] Uniq Affiliation ID
    #
    def current_id
      raise MissingCurrentId if Thread.current[THREAD_KEY].nil? && configuration.enforce_explicit_current_id

      Thread.current[THREAD_KEY] ||= SecureRandom.uuid
    end

    #
    # Sets a new ID to be used as Affiliation ID
    #
    # @param [String] value of Affilication ID
    #
    # @return [String] Affiliation ID
    #
    def current_id=(value)
      Thread.current[THREAD_KEY] = value
    end

    #
    # Renew the current Affiliation ID with a new one
    #
    # @return [String] Affiliation ID
    #
    def renew_current_id!
      Thread.current[THREAD_KEY] = SecureRandom.uuid
    end

    def reset!
      Thread.current[THREAD_KEY] = nil
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class MissingCurrentId < StandardError # :nodoc:
    def to_s
      'Affiliation ID must be set explicitly'
    end
  end
end
