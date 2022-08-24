# frozen_string_literal: true

module AffiliationId
  class Configuration # :nodoc:
    HEADER_NAME = 'X-Request-ID'
    attr_accessor :enforce_explicit_current_id, :header_name

    def initialize
      @enforce_explicit_current_id = true
      @header_name = HEADER_NAME
    end
  end
end
