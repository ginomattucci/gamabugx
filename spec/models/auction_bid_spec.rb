require 'rails_helper'

RSpec.describe AuctionBid, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:auction) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:value_in_credits) }

    context 'user_have_credits' do
      subject { build(:auction_bid, user: user, auction: build(:auction, bid_cost_in_credits: 5)) }

      context 'user without credits' do
        let!(:user) { create(:user, credits: 0) }
        it { is_expected.not_to be_valid }
      end

      context 'user with credits' do
        context 'user.credits > bid_cost_in_credits' do
          let!(:user) { create(:user, credits: 1000) }
          it { is_expected.to be_valid }
        end

        context 'user.credits == bid_cost_in_credits' do
          let!(:user) { create(:user, credits: 5) }
          it { is_expected.to be_valid }
        end

        context 'user.credits < bid_cost_in_credits' do
          let!(:user) { create(:user, credits: 3) }
          it { is_expected.not_to be_valid }
        end
      end
    end

    context 'active_auction' do
      subject { build(:auction_bid, auction: auction) }

      context 'finished auction' do
        let!(:auction) { build(:auction, ended_at: 1.second.from_now) }
        it { is_expected.not_to be_valid }
      end

      context 'valid auction' do
        let!(:auction) { build(:auction, ended_at: nil) }
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#refresh_auction' do
    it 'changes auction final_cost' do
      auction = create(:auction, final_cost: 0.0)
      expect{ create(:auction_bid, auction: auction) }.to change{auction.final_cost}.to eq(0.01)
    end
  end

  describe '#discount_user_credits' do
    it 'changes user credits' do
      user = create(:user, credits: 10)
      expect{ create(:auction_bid, value_in_credits: 2, user: user) }.to change{user.credits}.from(10).to(8)
    end
  end

  describe '#set_value' do
    context 'With auction' do
      context 'with value_in_credits set' do
        it 'not changes value_in_credits' do
          bid = build(:auction_bid, user: build(:user), value_in_credits: 10_234)
          expect{ bid.valid? }.not_to change{ bid.value_in_credits }
        end
      end

      context 'wihout value_in_credits' do
        it 'set value_in_credits with `auction.bid_cost_in_credits`' do
          bid = build(:auction_bid, user: build(:user), auction: build(:auction, bid_cost_in_credits: 19))
          bid.valid?
          expect(bid.value_in_credits).to eq(19)
        end
      end
    end

    context 'Without auction' do
      it 'not changes value_in_credits' do
        bid = build(:auction_bid, user: build(:user), auction: nil)
        expect{ bid.valid? }.not_to change{ bid.value_in_credits }
      end
    end
  end

  describe '#refound' do
    context 'Scheduled Auction with bids' do
      let(:user) { create(:user, credits: 5) }
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 1.hour.ago, bid_cost_in_credits: 1)}
      let(:bid) { create(:auction_bid, user: user, auction: auction) }

      subject { bid.refound }

      it 'Refound user credits' do
        expect(user.credits).to eq(5)
      end
      it 'Deletes bid' do
        is_expected.not_to be_persisted
      end
    end
  end
end
