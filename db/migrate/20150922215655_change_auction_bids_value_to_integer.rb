class ChangeAuctionBidsValueToInteger < ActiveRecord::Migration
  def change
    rename_column :auction_bids, :value, :value_in_credits
    change_column :auction_bids, :value_in_credits, :integer
  end
end
