# frozen_string_literal: true

require 'rack/mock'

require 'affiliation_id/middleware/rack'

RSpec.describe AffiliationId::Middleware::Rack do
  let(:env) { Rack::MockRequest.env_for }
  let(:app) { ->(_) { [200, {}, 'Response'] } }
  let(:middleware) { described_class.new(app) }

  describe '#call' do
    subject(:middleware_call) { middleware.call(env) }

    context 'without header' do
      it 'is set' do
        _, headers, = middleware_call

        expect(headers).to have_key(AffiliationId::HEADER_KEY)
      end
    end

    context 'with header' do
      let(:affiliation_id) { SecureRandom.uuid }
      let(:header_key) { "HTTP_#{AffiliationId::HEADER_KEY.upcase.tr('-', '_')}" }

      before do
        env[header_key] = affiliation_id
      end

      it 'is proxied' do
        _, headers, = middleware_call
        expect(headers[AffiliationId::HEADER_KEY]).to eq(affiliation_id)
      end

      context 'and its value includes unallowed characters' do
        let(:affiliation_id) { 'a!@#$%$*&()~`.1_-' }

        it 'sanitizes value to allowed characters only' do
          _, headers, = middleware_call
          expect(headers[AffiliationId::HEADER_KEY]).to eq('a@.1_-')
        end
      end

      context 'and its value is longer than allowed' do
        let(:affiliation_id) { 'a' * 300 }
        it 'strips down value to 255 characters' do
          _, headers, = middleware_call
          expect(headers[AffiliationId::HEADER_KEY].length).to eq(255)
        end
      end
    end
  end
end
