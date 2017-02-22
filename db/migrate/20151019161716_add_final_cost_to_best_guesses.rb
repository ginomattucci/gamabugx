class AddFinalCostToBestGuesses < ActiveRecord::Migration
  def change
    add_column :best_guesses, :final_cost, :decimal, default: 0
  end
end
