require 'rails_helper'

RSpec.describe Payment::Base do
  class DummyPaymentBaseTest < Payment::Base
    include IuguBase

    def self.payment_method
      :dummy
    end

    def payment_method
      self.class.payment_method
    end

    def due_date
      { due_date: '22/06/2015' }
    end

    def charge_param
      { method: 'dummy' }
    end
  end

  let!(:plan) { create(:plan) }
  let!(:attributes) { ActionController::Parameters.new(user: user) }
  let!(:user) { create(:user) }

  subject { DummyPaymentBaseTest.new(plan, attributes) }

  describe '#perform' do
    before do
      expect(Iugu::Invoice).to receive(:create).with({
        due_date: '22/06/2015',
        email: user.email,
        items: [
          { description: "#{Plan.model_name.human} #{plan.title}", quantity: 1, price_cents: (plan.price * 100).to_i },
        ]
      }).and_return(OpenStruct.new(id: 'some-random-id', secure_url: 'https://url.to/secure-invoice'))

      expect(Iugu::Charge).to receive(:create).with({
        method: 'dummy',
        invoice_id: 'some-random-id',
        payer: {
          email: user.email,
        }
      }).and_return(OpenStruct.new(success: success, pdf: 'http://url.to/file.pdf'))
    end

    context 'success' do
      let!(:success) { true }

      it { expect(subject.perform).to be true }

      xit 'sends an email' do
        expect{ subject.perform }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it 'creates a purchase' do
        expect{ subject.perform }.to change(Purchase, :count).by(1)
      end
    end

    context 'failure' do
      let!(:success) { false }

      it { expect(subject.perform).to be false }

      it 'not sends an email' do
        expect{ subject.perform }.not_to change(ActionMailer::Base.deliveries, :count)
      end

      it 'not creates a purchase' do
        expect{ subject.perform }.not_to change(Purchase, :count)
      end
    end
  end

  describe '#redirect_path' do
    context 'success' do
      before { is_expected.to receive(:success?).and_return(true) }
      before { expect(subject.purchase).to receive(:invoice).and_return('my-id') }

      let!(:expected) { [Rails.application.routes.url_helpers.checkout_success_path('my-id'), flash: { notice: "Compra realizada com sucesso!" }] }

      it { expect(subject.redirect_path).to eq(expected) }
    end

    context 'failure' do
      before { is_expected.to receive(:success?).and_return(false) }

      context 'charge with message of error' do
        before { is_expected.to receive(:charge).and_return(OpenStruct.new(message: 'Cartão recusado pela operadora')) }

        let!(:expected) { [Rails.application.routes.url_helpers.plans_path, flash: { charge_messages: 'Cartão recusado pela operadora' } ]}

        it { expect(subject.redirect_path).to eq(expected) }
      end

      context 'charge without message' do
        let!(:expected) { [Rails.application.routes.url_helpers.plans_path, flash: { charge_messages: 'Verifique os dados digitados' } ]}

        it { expect(subject.redirect_path).to eq(expected) }
      end
    end
  end
end
