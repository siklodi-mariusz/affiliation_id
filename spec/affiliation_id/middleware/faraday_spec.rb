# frozen_string_literal: true

require 'affiliation_id/middleware/faraday'

RSpec.describe AffiliationId::Middleware::Faraday do
  let(:header_name) { AffiliationId.configuration.header_name }
  let(:conn) do
    Faraday.new do |f|
      f.request :affiliation_id
      f.adapter :test do |stub|
        stub.get('/affiliate') do |env|
          [200, {}, env[:request_headers][header_name]]
        end
      end
    end
  end

  describe '#call' do
    subject(:response) { conn.get('/affiliate') }

    context 'when request headers do not include affiliation_id' do
      let(:affiliation_id) { SecureRandom.uuid }

      before do
        allow(AffiliationId).to receive(:current_id).and_return(affiliation_id)
      end

      it 'includes AffiliationId.current_id in the headers' do
        expect(response.body).to eq(affiliation_id)
      end
    end

    context 'when request headers already include affiliation_id' do
      subject(:response) { conn.get('/affiliate', nil, header_name => 'test') }

      it 'does not interfere with existing header' do
        expect(response.body).to eq('test')
      end
    end
  end
end
