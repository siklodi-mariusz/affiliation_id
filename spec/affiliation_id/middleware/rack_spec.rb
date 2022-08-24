# frozen_string_literal: true

require 'rack/mock'

require 'affiliation_id/middleware/rack'

RSpec.describe AffiliationId::Middleware::Rack do
  let(:header_name) { AffiliationId.configuration.header_name }
  let(:env) { Rack::MockRequest.env_for }
  let(:app) { ->(_) { [200, {}, 'Response'] } }
  let(:middleware) { described_class.new(app) }

  shared_examples 'reseting AffiliationId' do
    specify do
      expect(AffiliationId).to receive(:reset!)
      middleware_call
    end
  end

  describe '#call' do
    subject(:middleware_call) { middleware.call(env) }

    context 'without header' do
      it 'is set' do
        _, headers, = middleware_call

        expect(headers).to have_key(header_name)
      end

      it_behaves_like 'reseting AffiliationId'
    end

    context 'with header' do
      let(:affiliation_id) { SecureRandom.uuid }
      let(:header_key) { "HTTP_#{header_name.upcase.tr('-', '_')}" }

      before do
        env[header_key] = affiliation_id
      end

      it 'is proxied' do
        _, headers, = middleware_call
        expect(headers[header_name]).to eq(affiliation_id)
      end

      context 'and its value includes unallowed characters' do
        let(:affiliation_id) { 'a!@#$%$*&()~`.1_-' }

        it 'sanitizes value to allowed characters only' do
          _, headers, = middleware_call
          expect(headers[header_name]).to eq('a@.1_-')
        end
      end

      context 'and its value is longer than allowed' do
        let(:affiliation_id) { 'a' * 300 }
        it 'strips down value to 255 characters' do
          _, headers, = middleware_call
          expect(headers[header_name].length).to eq(255)
        end
      end

      it_behaves_like 'reseting AffiliationId'
    end
  end
end
