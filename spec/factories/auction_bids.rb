FactoryGirl.define do
  factory :auction_bid do
    user
    auction
    value_in_credits { auction.bid_cost_in_credits if auction }
  end
end
