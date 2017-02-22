require 'rails_helper'

RSpec.describe Payment::CreditCard do
  let!(:plan) { create(:plan) }
  let!(:attributes) { ActionController::Parameters.new(user: user, token: 'awsome-token') }
  let!(:user) { create(:user) }

  subject { described_class.new(plan, attributes) }

  describe '#payment_method' do
    it { expect(subject.send(:payment_method)).to eq(:credit_card) }
  end

  describe '#due_date' do
    it 'returns a hash with due_date of today' do
      expect(Date).to receive(:tomorrow).and_return(Date.new(2015, 10, 30))
      expected = { due_date: '30/10/2015' }
      expect(subject.send(:due_date)).to eq(expected)
    end
  end

  describe '#charge_param' do
    context 'with months' do
      context 'with months >= 2' do
        let(:attributes) do
          ActionController::Parameters.new(user: user,
                                           token: 'awsome-token',
                                           months: '2')
        end

        it 'returns a hash with token and months' do
          expected = { token: 'awsome-token', months: 2 }
          expect(subject.send(:charge_param)).to eq(expected)
        end
      end

      context 'with months == 1' do
        let!(:attributes) do
          ActionController::Parameters.new(user: user,
                                           token: 'awsome-token',
                                           months: '1')
        end
        it 'returns a hash with token' do
          expect(subject.send(:charge_param)).to eq({ token: 'awsome-token' })
        end
      end
    end

    context 'without months' do
      it 'returns a hash with token' do
        expect(subject.send(:charge_param)).to eq({ token: 'awsome-token' })
      end
    end
  end
end
