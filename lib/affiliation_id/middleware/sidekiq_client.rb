# frozen_string_literal: true

require_relative '../../affiliation_id'

module AffiliationId
  module Middleware
    #
    # Sidekiq client middleware to inject the AffiliationId.current_id in the Job
    #
    # When Sidekiq client pushes a job in queue, at minimum, the job contains the following attributes:
    #
    #   {
    #     "class": "SomeWorker",
    #     "jid": "b4a577edbccf1d805744efa9", // 12-byte random number as 24 char hex string
    #     "args": [1, "arg", true],
    #     "created_at": 1234567890,
    #     "enqueued_at": 1234567890
    #   }
    #
    # This middleware adds to this list of attributes the current value of AffiliationId.current_id.
    # So, if AffiliationId.current_id returns a value of "93f971bb-b889-4223-ac57-5d39f34051a4",
    # the end result will look something like this:
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
    #
    class SidekiqClient
      def call(_, job, _, _)
        job[::AffiliationId::SIDEKIQ_JOB_KEY] = ::AffiliationId.current_id
        yield
      end
    end
  end
end
