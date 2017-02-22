class CreateAuctionBids < ActiveRecord::Migration
  def change
    create_table :auction_bids do |t|
      t.references :user, index: true, foreign_key: true
      t.references :auction, index: true, foreign_key: true
      t.decimal :value

      t.timestamps null: false
    end
  end
end
