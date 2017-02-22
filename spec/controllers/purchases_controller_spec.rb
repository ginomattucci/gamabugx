require 'rails_helper'

RSpec.describe PurchasesController, type: :controller do
  let!(:user) { create(:user) }

  describe 'GET #index' do
    context 'guest user' do
      it 'returns http success' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'signed user' do
      before do
        login_user(user)
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      xit 'assigns @purchases' do
        expect(subject).to assigns(:purchases)
      end
    end
  end
end
