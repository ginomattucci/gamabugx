require 'rails_helper'

describe AuctionBidPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions :create? do
    it "denies access if guest user" do
      is_expected.not_to permit(nil, build(:auction_bid))
    end

    context "signed user" do
      let!(:user) { create(:user) }
      let!(:auction) { create(:auction) }

      context 'auction with bids' do
        before { create(:auction_bid, user: current_bid_user, auction: auction) }

        context 'last bid user != current_user' do
          let(:current_bid_user) { create(:user) }

          it "grants access if last bid user != user" do
            is_expected.to permit(user, build(:auction_bid, user: user, auction: auction))
          end
        end
      end
    end
  end
end
