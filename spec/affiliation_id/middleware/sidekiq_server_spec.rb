# frozen_string_literal: true

require 'affiliation_id/middleware/sidekiq_server'

RSpec.describe AffiliationId::Middleware::SidekiqServer do
  describe '#call' do
    let(:affiliation_id) { SecureRandom.uuid }
    let(:middleware_instance) { described_class.new }

    subject(:middleware_call) { middleware_instance.call(nil, job, nil) { 'Test' } }

    shared_examples 'a middleware that ensures the AffiliationId.reset! is called' do
      before do
        allow(AffiliationId).to receive(:reset!)
      end

      context 'when no error is raised' do
        specify do
          middleware_call
          expect(AffiliationId).to have_received(:reset!)
        end
      end

      context 'when error is raised' do
        specify do
          expect { middleware_instance.call(nil, job, nil) { raise StandardError, 'Test' } }.to(
            raise_error(StandardError, 'Test')
          )
          expect(AffiliationId).to have_received(:reset!)
        end
      end
    end

    context 'when job includes an affiliation_id' do
      let(:job) { { AffiliationId::SIDEKIQ_JOB_KEY => affiliation_id } }

      it 'yields control' do
        expect { |b| middleware_instance.call(nil, job, nil, &b) }.to yield_with_no_args
      end

      it 'sets AffiliationId.current_id= to value from job' do
        expect(AffiliationId).to receive(:current_id=).with(affiliation_id)
        middleware_call
      end

      it_behaves_like 'a middleware that ensures the AffiliationId.reset! is called'
    end

    context 'when job does not include an affiliation_id' do
      let(:job) { {} }
      let(:affiliation_id) { SecureRandom.uuid }

      before do
        allow(AffiliationId).to receive(:current_id).and_return(affiliation_id)
      end

      it 'yields control' do
        expect { |b| middleware_instance.call(nil, job, nil, &b) }.to yield_with_no_args
      end

      it 'sets AffiliationId.current_id= to fallback AffiliationId.current_id' do
        expect(AffiliationId).to receive(:current_id=).with(affiliation_id)
        middleware_call
      end

      it_behaves_like 'a middleware that ensures the AffiliationId.reset! is called'
    end
  end
end
