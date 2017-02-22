class AddMarketPriceToBestGuesses < ActiveRecord::Migration
  def change
    add_column :best_guesses, :market_price, :decimal
  end
end
