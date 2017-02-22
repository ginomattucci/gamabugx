require 'rails_helper'

RSpec.describe Payment::Base do
  let!(:plan) { create(:plan) }
  let!(:attributes) { ActionController::Parameters.new(user: user) }
  let!(:user) { create(:user) }

  subject { described_class.new(plan, attributes) }

  describe 'initializer' do
    let!(:attributes) { ActionController::Parameters.new(user: user, bla: 'foo') }

    it 'sets #user' do
      expect(subject.user).to eq(attributes[:user])
    end

    it 'sets #plan' do
      expect(subject.plan).to eq(plan)
    end

    it 'not sets unknow attributes' do
      expect{ subject.bla }.to raise_error(NoMethodError)
    end
  end

  describe '.payment_methods' do
    it 'returns an array with bank slip' do
      expect(described_class.payment_methods).to include([I18n.t('payment.bank_slip'), :bank_slip])
    end

    it 'returns an array with bank slip' do
      expect(described_class.payment_methods).to include([I18n.t('payment.credit_card'), :credit_card])
    end
  end

  describe '#perform' do
    it { expect{ subject.perform }.to raise_error(NotImplementedError) }
  end

  describe '#success?' do
    it { expect{ subject.success? }.to raise_error(NotImplementedError) }
  end

  describe '#save_purchase' do
    it { expect{ subject.save_purchase }.to raise_error(NotImplementedError) }
  end

  describe '#send_mail' do
    it { expect{ subject.send_mail }.to raise_error(NotImplementedError) }
  end

  describe '#payment_method' do
    it { expect{ subject.payment_method }.to raise_error(NotImplementedError) }
  end

  describe '#redirect_path' do
    it { expect{ subject.redirect_path }.to raise_error(NotImplementedError) }
  end

  describe '#purchase' do
    before { expect(subject).to receive(:payment_method).and_return('payment_method') }

    it { expect(subject.purchase).to be_a(Purchase) }

    it 'belongs to user' do
      expect(subject.purchase.user).to eq(user)
    end

    it 'not changes user.purchases without invoice_id' do
      expect{ subject.purchase.save }.not_to change(user.purchases, :count)
    end
  end

  describe '#finish_purchase' do
    after { subject.finish_purchase }

    context 'with everything ok' do
      before { allow(subject).to receive(:save_purchase).and_return(true) }
      before { allow(subject).to receive(:send_mail).and_return(true) }

      it 'calls save_purchase' do
        is_expected.to receive(:save_purchase).once
      end

      it 'calls send_mail' do
        is_expected.to receive(:send_mail).once
      end
    end

    context 'with save_purchase failing' do
      before { allow(subject).to receive(:save_purchase).and_return(false) }
      before { allow(subject).to receive(:send_mail).and_return(true) }

      it 'calls save_purchase' do
        is_expected.to receive(:save_purchase).once
      end

      it 'not calls send_mail' do
        is_expected.not_to receive(:send_mail)
      end
    end

    context 'with send_mail failing' do
      before { allow(subject).to receive(:save_purchase).and_return(true) }
      before { allow(subject).to receive(:send_mail).and_return(false) }

      it 'calls save_purchase' do
        is_expected.to receive(:save_purchase).once
      end

      it 'calls send_mail' do
        is_expected.to receive(:send_mail).once
      end
    end
  end
end
