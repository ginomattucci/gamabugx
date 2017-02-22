require 'rails_helper'

RSpec.describe CheckoutsController, type: :controller do
  include ActionView::Helpers::NumberHelper

  let!(:plan) { create(:plan) }
  let!(:user) { create(:user) }
  let!(:bank_slip_attributes) { { payment_method: 'bank_slip', plan_id: plan.id } }

  describe 'POST #create' do
    context 'guest user' do
      it 'redirect to /users/sign_in' do
        post :create, purchase: bank_slip_attributes
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'user signed in' do
      before { login_user(user) }

      context 'success payment' do
        before do
          invoice_id = "0958D2AAD34049AB889583E26DFA0BF1"
          due_date = attributes[:payment_method] == 'bank_slip' ? Date.today : Date.tomorrow

          body = {
            due_date: due_date.in_time_zone.strftime('%d/%m/%Y'),
            email: user.email,
            items: [
              {
                description: "#{plan.model_name.human} #{plan.title}",
                quantity: 1,
                price_cents: (plan.price * 100).to_i
              }
            ]
          }.to_json

          response_body = {
            id: invoice_id,
            due_date: due_date.to_s,
            currency: "BRL",
            discount_cents: nil,
            email: user.email,
            items_total_cents: (plan.price * 100).to_i,
            notification_url: nil,
            return_url: nil,
            status: "pending",
            tax_cents: nil,
            updated_at: DateTime.now.iso8601,
            total_cents: 1000,
            paid_at: nil,
            secure_id: "0958d2aa-d340-49ab-8895-83e26dfa0bf1-2f4c",
            secure_url: "http://iugu.com/invoices/0958d2aa-d340-49ab-8895-83e26dfa0bf1-2f4c",
            customer_id: nil,
            user_id: nil,
            total: number_to_currency(plan.price),
            taxes_paid: "R$ 0,00",
            interest: nil,
            discount: nil,
            created_at: "17/06, 09:58 h",
            refundable: nil,
            installments: nil,
            bank_slip: {
              digitable_line: "00000000000000000000000000000000000000000000000",
              barcode_data: "00000000000000000000000000000000000000000000",
              barcode: "http://iugu.com/invoices/barcode/0958d2aa-d340-49ab-8895-83e26dfa0bf1-2f4c"
            },
            items: [{
              id: SecureRandom.hex(16),
              description: "Item Um",
              price_cents: (plan.price * 100).to_i,
              quantity: 1,
              created_at: DateTime.now.iso8601,
              updated_at: DateTime.now.iso8601,
              price: number_to_currency(plan.price)
            }],
            variables: [],
            custom_variables: [],
            logs: []
          }
          stub_request(:post, "https://#{Iugu.api_key}:@api.iugu.com/v1/invoices").
            with(body: body,
                 headers: {accept: 'application/json', accept_charset:'utf-8', accept_encoding: 'gzip, deflate', accept_language: 'pt-br;q=0.9,pt-BR', content_length: "#{body.size}", content_type:'application/json; charset=utf-8', user_agent:'Iugu RubyLibrary'}).
            to_return(status: 201, body: response_body.to_json, headers: {})


          body = "{\"method\":\"#{attributes[:payment_method]}\",\"invoice_id\":\"#{invoice_id}\",\"payer\":{\"email\":\"#{user.email}\"}}"
          stub_request(:post, "https://#{Iugu.api_key}:@api.iugu.com/v1/charge").
            with(body: body,
                 headers: {accept: 'application/json', accept_charset: 'utf-8', accept_encoding: 'gzip, deflate', accept_language: 'pt-br;q=0.9,pt-BR', content_length: "#{body.size}", content_type: 'application/json; charset=utf-8', user_agent: 'Iugu RubyLibrary'}).
            to_return(status: 200, body: {
                   errors: {},
                   url: "http://bank_slip_url",
                   success: true,
                   invoice_id: invoice_id
                 }.to_json, headers: {})
        end

        context 'bank slip' do
          let!(:attributes) { bank_slip_attributes }

          it 'creates a Purchase' do
            expect{
              post :create, purchase: attributes
            }.to change(Purchase, :count).by(1)
          end

          it 'redirect to success page' do
            post :create, purchase: attributes

            expected_id = Purchase.last.invoice
            expect(response).to redirect_to(checkout_success_path(expected_id))
          end
        end
      end
    end
  end

  describe 'GET #success' do
    context 'guest user' do
    end

    context 'user signed in' do
      it 'returns http success' do
      end
    end
  end
end
