require 'rails_helper'

RSpec.describe Checkout do
  describe '.perform' do
    subject { described_class.perform(plan, attributes) }
    let!(:user) { create(:user) }

    context 'Invalid payment method' do
      let!(:plan) { create(:plan) }
      let!(:attributes) { ActionController::Parameters.new() }

      it 'returns checkout_path with flash alert to try again' do
        expected = [Rails.application.routes.url_helpers.plans_path, flash: { alert: 'Tente novamente' }]
        is_expected.to eq(expected)
      end
    end

    context 'Valid payment method' do
      let!(:plan) { create(:plan) }

      context 'Bank slip' do
        let!(:attributes) { ActionController::Parameters.new(payment_method: 'bank_slip', user: user) }

        before { expect_any_instance_of(Payment::BankSlip).to receive(:perform).once }
        before { expect_any_instance_of(Payment::BankSlip).to receive(:redirect_path).once }

        it 'calls Payment::BankSlip' do
          described_class.perform(plan, attributes)
        end
      end

      context 'Credit Card' do
        let!(:attributes) { ActionController::Parameters.new(payment_method: 'credit_card', user: user) }

        before { expect_any_instance_of(Payment::CreditCard).to receive(:perform).once }
        before { expect_any_instance_of(Payment::CreditCard).to receive(:redirect_path).once }

        it 'calls Payment::CreditCard' do
          described_class.perform(plan, attributes)
        end
      end
    end
  end
end
