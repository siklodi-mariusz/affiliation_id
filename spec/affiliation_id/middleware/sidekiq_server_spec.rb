# frozen_string_literal: true

require 'affiliation_id/middleware/sidekiq_server'

RSpec.describe AffiliationId::Middleware::SidekiqServer do
  describe '#call' do
    let(:affiliation_id) { SecureRandom.uuid }
    let(:middleware_instance) { described_class.new }

    subject(:middleware_call) { middleware_instance.call(nil, job, nil) { 'Test' } }

    context 'when job includes an affiliation_id' do
      let(:job) { { AffiliationId::SIDEKIQ_JOB_KEY => affiliation_id } }

      it 'yields control' do
        expect { |b| middleware_instance.call(nil, job, nil, &b) }.to yield_with_no_args
      end

      it 'sets AffiliationId.current_id= to value from job' do
        expect(AffiliationId).to receive(:current_id=).with(affiliation_id)
        middleware_call
      end
    end

    context 'when job does not include an affiliation_id' do
      let(:job) { {} }
      let(:affiliation_id) { AffiliationId.current_id }

      it 'yields control' do
        expect { |b| middleware_instance.call(nil, job, nil, &b) }.to yield_with_no_args
      end

      it 'sets AffiliationId.current_id= to fallback AffiliationId.current_id' do
        expect(AffiliationId).to receive(:current_id=).with(affiliation_id)
        middleware_call
      end
    end
  end
end
