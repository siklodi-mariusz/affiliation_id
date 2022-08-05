# frozen_string_literal: true

RSpec.describe AffiliationId do
  it 'has a version number' do
    expect(AffiliationId::VERSION).not_to be nil
  end

  describe '.current_id' do
    subject { described_class.current_id }

    it { is_expected.to be }

    it 'returns the same id on multiple calls' do
      expect(Array.new(5) { described_class.current_id }.uniq).to be_one
    end
  end

  describe '.current_id=' do
    let(:new_id) { SecureRandom.uuid }
    subject { described_class.current_id = new_id }

    it 'changes current_id' do
      expect { subject }.to change { described_class.current_id }.to(new_id)
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
end
