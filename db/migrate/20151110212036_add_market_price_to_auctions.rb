class AddMarketPriceToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :market_price, :decimal
  end
end
