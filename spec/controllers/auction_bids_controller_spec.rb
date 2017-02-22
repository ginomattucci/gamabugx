require 'rails_helper'

RSpec.describe AuctionBidsController, type: :controller do
  before do
    # Skip Pubnub publish in tests
    allow(GameNotification).to receive(:publish).and_return(nil)
  end

  describe 'POST #create' do
    let!(:auction) { create(:auction, winner: nil, happens_at: 2.hours.from_now) }

    context 'Guest users' do
      before { post :create, auction_id: auction.to_param }

      it { expect(response.status).to eq(302) }
      it { expect(response).to redirect_to(new_user_session_path) }

      context 'flash message' do
        it { expect(flash).not_to be_empty }
        it { expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated') }
      end
    end

    context 'Signed users' do
      before do
        login_user(user)
        post :create, { auction_id: auction.to_param }
      end

      context 'with credits' do
        let!(:user) { create(:user, credits: 1_000) }

        context 'ended auction' do
          let!(:auction) { create(:auction, winner: user, ended_at: 2.hours.ago)}

          it { expect(response.status).to eq(302) }
          it { expect(response).to redirect_to(auction_path(auction)) }
          it 'not create ah AuctionBid' do
            expect{
              post :create, { auction_id: auction.to_param }
            }.not_to change(AuctionBid, :count)
          end

          context 'flash message' do
            it { expect(flash).not_to be_empty }
            it { expect(flash[:alert]).to eq I18n.t('auction_bids.fail') }
          end
        end

        context 'auction in progress' do
          it { expect(response.status).to eq(302) }
          it { expect(response).to redirect_to(auction_path(auction)) }

          context 'flash message' do
            it { expect(flash).not_to be_empty }
            it { expect(flash[:notice]).to eq I18n.t('auction_bids.success') }
          end
        end
      end

      context 'without credits' do
        let!(:user) { create(:user, credits: 0) }

        it { expect(response.status).to eq(302) }
        it { expect(response).to redirect_to(root_path) }

        context 'flash message' do
          it { expect(flash).not_to be_empty }
          it { expect(flash[:alert]).to eq I18n.t('auction_bids.missing_credits') }
        end
      end
    end
  end
end
