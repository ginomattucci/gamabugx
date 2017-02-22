require 'spec_helper'

describe AuctionDecorator do
  context '#last_bidder' do
    subject { auction.decorate.last_bidder }
    let!(:auction) { build(:auction) }

    context 'Auction without bids' do
      it { is_expected.to eq "---" }
    end
    context 'Auction with many bid' do
      let!(:first_bid) { create(:auction_bid, auction: auction, created_at: 30.seconds.ago) }
      let!(:last_bid) { create(:auction_bid, auction: auction, created_at: Time.now) }

      it 'Gets the last bid' do
        is_expected.to eq last_bid.user.username
      end
    end

  end
end
