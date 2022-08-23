# frozen_string_literal: true

RSpec.describe AffiliationId do
  it 'has a version number' do
    expect(AffiliationId::VERSION).not_to be nil
  end

  before { described_class.reset! }

  describe '.current_id' do
    subject { described_class.current_id }

    around do |example|
      old_value = described_class.configuration.enforce_explicit_current_id
      described_class.configuration.enforce_explicit_current_id = enforce_explicit_current_id_value
      example.call
      described_class.configuration.enforce_explicit_current_id = old_value
    end

    context 'when config :enforce_explicit_current_id set to true' do
      let(:enforce_explicit_current_id_value) { true }

      context 'and current_id is not set explicitly' do
        it 'raises error' do
          expect { subject }.to raise_error(AffiliationId::MissingCurrentId)
        end
      end

      context 'and current_id is set explicitly' do
        before do
          described_class.current_id = 'test'
        end

        it 'returns the same id on multiple calls' do
          expect(Array.new(5) { described_class.current_id }.uniq).to be_one
        end
      end
    end

    context 'when config :enforce_explicit_current_id set to false' do
      let(:enforce_explicit_current_id_value) { false }

      it { is_expected.to be }

      it 'returns the same id on multiple calls' do
        expect(Array.new(5) { described_class.current_id }.uniq).to be_one
      end
    end
  end

  describe '.current_id=' do
    let(:new_id) { SecureRandom.uuid }
    subject { described_class.current_id = new_id }

    it 'changes current_id' do
      expect(subject).to eq(described_class.current_id)
    end

    it 'delegates to Thread.current' do
      expect { subject }.to change { Thread.current[described_class::THREAD_KEY] }.from(nil).to(new_id)
    end
  end

  describe '.renew_current_id!' do
    subject { described_class.renew_current_id! }

    it 'generates current_id' do
      expect(subject).to be
    end

    it 'generates new current_id on each call' do
      expect(Array.new(5) { described_class.renew_current_id! }.uniq.length).to eq(5)
    end

    it 'stores the new current_id for future calls' do
      renewed = subject
      expect(renewed).to eq(described_class.current_id)
    end
  end

  describe '.reset!' do
    subject { described_class.reset! }

    before do
      Thread.current[described_class::THREAD_KEY] = 'Test'
    end

    it 'clears Thread.current' do
      expect { subject }.to change { Thread.current[described_class::THREAD_KEY] }.from('Test').to(nil)
    end
  end

  describe '.configure' do
    it 'yields configuration object' do
      expect { |b| described_class.configure(&b).to yield_with_args(AffiliationId::Configuration) }
    end
  end
end
