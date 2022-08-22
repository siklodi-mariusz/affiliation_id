# frozen_string_literal: true

require_relative '../../affiliation_id'

module AffiliationId
  module Middleware
    #
    # Sidekiq server middleware to set AffiliationId.current_id from the job hash
    #
    # Assuming AffiliationId::Middleware::SidekiqClient is used.
    # All jobs pushed in the queue will include an affiliation_id
    #
    #   {
    #     "class": "SomeWorker",
    #     "jid": "b4a577edbccf1d805744efa9", // 12-byte random number as 24 char hex string
    #     "args": [1, "arg", true],
    #     "created_at": 1234567890,
    #     "enqueued_at": 1234567890,
    #     "affiliation_id": "93f971bb-b889-4223-ac57-5d39f34051a4"
    #   }
    #
    # This middleware will take that value and set AffiliationId.current_id= to it.
    #
    # If there is no affiliation_id attribute in the job Hash, there is a fallback to AffiliationId.current_id,
    # which generates a new one if it's not set.
    #
    class SidekiqServer
      def call(_, job, _)
        ::AffiliationId.current_id = job[::AffiliationId::SIDEKIQ_JOB_KEY] || ::AffiliationId.current_id
        yield
      end
    end
  end
end
