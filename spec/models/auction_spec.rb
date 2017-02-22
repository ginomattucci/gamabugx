require 'rails_helper'

RSpec.describe Auction, type: :model do
  before { allow(GameNotification).to receive(:publish).and_return(nil) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :image }
    it { is_expected.to validate_presence_of :description_url }
    it { is_expected.to validate_presence_of :happens_at }
    it { is_expected.to validate_presence_of :bid_cost_in_credits }
    it { is_expected.to validate_presence_of :market_price }
    it { is_expected.to allow_value("http://example.com").for(:description_url) }
    it { is_expected.to allow_value("https://example.com").for(:description_url) }
    it { is_expected.to allow_value("https://www.example.com").for(:description_url) }
    it { is_expected.not_to allow_value("www.example.com").for(:description_url) }
    it { is_expected.not_to allow_value("example.com").for(:description_url) }
  end

  describe 'Predicates' do
    subject { auction }

    context 'Sold auction' do
      context 'ended one month ago' do
        let!(:auction) { build(:auction, ended_at: 1.month.ago, winner: build(:user), happens_at: 2.months.ago) }
        it { is_expected.to be_sold }
        it { is_expected.to be_finished }
        it { is_expected.not_to be_active }
        it { is_expected.not_to be_scheduled }
        it { is_expected.not_to be_claimable }
      end
      context 'ended 5 days ago' do
        let!(:auction) { build(:auction, ended_at: 5.days.ago, winner: build(:user), happens_at: 6.days.ago) }
        it { is_expected.to be_sold }
        it { is_expected.to be_finished }
        it { is_expected.not_to be_active }
        it { is_expected.not_to be_scheduled }
        it { is_expected.to be_claimable }
      end
    end

    context 'Scheduled auction' do
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 2.hours.from_now) }
      it { is_expected.to be_scheduled }
      it { is_expected.not_to be_finished }
      it { is_expected.not_to be_sold }
      it { is_expected.not_to be_active }
      it { is_expected.not_to be_claimable }
    end

    context 'Active auction' do
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 1.hour.ago) }
      it { is_expected.to be_active }
      it { is_expected.not_to be_finished }
      it { is_expected.not_to be_scheduled }
      it { is_expected.not_to be_sold }
      it { is_expected.not_to be_claimable }
    end

    context 'Finished without winner auction' do
      let!(:auction) { build(:auction, ended_at: 1.hour.ago, winner: nil, happens_at: 2.hour.ago) }
      it { is_expected.to be_finished }
      it { is_expected.not_to be_active }
      it { is_expected.not_to be_scheduled }
      it { is_expected.not_to be_sold }
      it { is_expected.not_to be_claimable }
    end
  end

  describe '#check_winner' do
    subject { auction }
    context 'Auction with a winning bid' do
      let!(:expected_ends_at) { Time.now }
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 1.hour.ago) }
      let!(:bid) { create(:auction_bid, auction: auction, created_at: Time.now) }
      let!(:last_bid) { create(:auction_bid, auction: auction, created_at: (auction.countdown_timer + 1).seconds.ago) }

      before do
        expect(Time).to receive(:now).and_return(expected_ends_at).at_least(1)
        auction.check_winner
      end

      it 'Sells the auction' do
        expect(auction.sold?).to eq(true)
      end

      it 'Sets the winner' do
        expect(auction.winner).to eq(last_bid.user)
      end

      it 'Ends the auction' do
        expect(auction.ended_at).to eq(expected_ends_at)
        expect(auction.finished?).to eq(true)
      end
    end
    context 'Auction with a non-winning bid' do
      let!(:expected_ends_at) { Time.now }
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 1.hour.ago) }
      let!(:bid) { create(:auction_bid, auction: auction, created_at: Time.now) }
      let!(:last_bid) { create(:auction_bid, auction: auction, created_at: (auction.countdown_timer - 1).seconds.ago) }

      before do
        expect(Time).to receive(:now).and_return(expected_ends_at).at_least(1)
        auction.check_winner
      end

      it "Doesn't sell the auction" do
        expect(auction.sold?).to eq(false)
      end

      it "Doesn't set the winner" do
        expect(auction.winner).to eq(nil)
      end

      it "Doesn't end the auction" do
        expect(auction.finished?).to eq(false)
      end
    end

    context 'Auction without a bid' do
      let!(:expected_ends_at) { Time.now }
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 1.hour.ago) }

      before do
        expect(Time).to receive(:now).and_return(expected_ends_at).at_least(1)
        auction.check_winner
      end

      it "Doesn't sell the auction" do
        expect(auction.sold?).to eq(false)
      end

      it "Doesn't set the winner" do
        expect(auction.winner).to eq(nil)
      end

      it 'Ends the auction' do
        expect(auction.ended_at).to eq(expected_ends_at)
        expect(auction.finished?).to eq(true)
      end
    end
  end

  describe '#cancel' do
    context 'Simple Auction' do
      let!(:expected_ended_at) { Time.now }
      let!(:auction) { build(:auction, ended_at: nil, winner: nil, happens_at: 1.hour.ago)}
      let!(:bid1) {create(:auction_bid, user: create(:user), auction: auction)}
      let!(:bid2) {create(:auction_bid, user: create(:user), auction: auction)}
      let!(:bid3) {create(:auction_bid, user: create(:user), auction: auction)}

      before do
        expect(Time).to receive(:now).and_return(expected_ended_at).at_least(1)
      end

      it 'Refounds every bid' do
        expect{ auction.cancel }.to change {auction.bids.count}.from(3).to(0)
      end

      it 'Finishes the auction' do
        expect{ auction.cancel }.to change {auction.ended_at}.from(nil).to(expected_ended_at)
      end
    end
  end
end
