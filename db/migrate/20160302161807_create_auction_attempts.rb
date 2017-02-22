class CreateAuctionAttempts < ActiveRecord::Migration
  def change
    create_table :auction_attempts do |t|
      t.references :auction, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :credits

      t.timestamps null: false
    end
    add_column :auctions, :join_cost_in_credits, :integer
    add_column :auctions, :tournament, :boolean, default: false
    add_column :auctions, :max_attempts, :integer
    add_column :best_guesses, :tournament, :boolean, default: false
    add_column :auctions, :players, :integer
    add_column :best_guesses, :players, :integer
    add_reference :auction_bids, :auction_attempt, index: true
  end
end
