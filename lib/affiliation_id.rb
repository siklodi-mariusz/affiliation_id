# frozen_string_literal: true

require 'securerandom'

require_relative 'affiliation_id/version'

module AffiliationId # :nodoc:
  HEADER_KEY      = 'X-Affiliation-ID'
  THREAD_KEY      = 'AFFILIATION_ID'
  SIDEKIQ_JOB_KEY = 'affiliation_id'

  class << self
    #
    # Returns the current Affiliation ID
    #
    # @return [String] Uniq Affiliation ID
    #
    def current_id
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
  end
end
