# frozen_string_literal: true

module AffiliationId
  class Configuration # :nodoc:
    attr_accessor :enforce_explicit_current_id

    def initialize
      @enforce_explicit_current_id = true
    end
  end
end
