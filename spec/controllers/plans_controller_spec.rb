require 'rails_helper'

RSpec.describe PlansController, type: :controller do

  let!(:user) { create(:user) }

  describe "GET #index" do
    context 'guest user' do
      it "returns http success" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'signed user' do
      before { login_user(user) }

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

end
