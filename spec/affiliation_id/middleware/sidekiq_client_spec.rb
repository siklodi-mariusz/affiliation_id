# frozen_string_literal: true

require 'affiliation_id/middleware/sidekiq_client'

RSpec.describe AffiliationId::Middleware::SidekiqClient do
  describe '#call' do
    let(:job) { {} }
    let(:affiliation_id) { SecureRandom.uuid }
    let(:middleware_instance) { described_class.new }

    before do
      allow(AffiliationId).to receive(:current_id).and_return(affiliation_id)
    end

    it 'yields control' do
      expect { |b| middleware_instance.call(nil, job, nil, nil, &b) }.to yield_with_no_args
    end

    it 'injects affiliation_id' do
      expect { middleware_instance.call(nil, job, nil, nil) { 'Test' } }.to(
        change { job[AffiliationId::SIDEKIQ_JOB_KEY] }.from(nil).to(affiliation_id)
      )
    end
  end
end
