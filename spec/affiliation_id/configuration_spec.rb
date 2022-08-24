# frozen_string_literal: true

require 'affiliation_id/configuration'

RSpec.describe AffiliationId::Configuration do
  subject(:instance) { described_class.new }

  describe '#enforce_explicit_current_id' do
    subject { instance.enforce_explicit_current_id }

    it { expect(instance).to respond_to(:enforce_explicit_current_id) }
    it { expect(instance).to respond_to(:enforce_explicit_current_id=) }

    it 'is true by default' do
      is_expected.to eq(true)
    end
  end

  describe '#header_name' do
    subject { instance.header_name }

    it { expect(instance).to respond_to(:header_name) }
    it { expect(instance).to respond_to(:header_name=) }

    it 'is X-Request-ID by default' do
      is_expected.to eq('X-Request-ID')
    end
  end
end
