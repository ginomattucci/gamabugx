class AddIncreaseValueToGames < ActiveRecord::Migration
  def change
    add_column :auctions, :increase_value, :integer, default: 1
    add_column :best_guesses, :increase_value, :integer, default: 1
  end
end
