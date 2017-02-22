class AddValueInCreditsToBestGuessAttempts < ActiveRecord::Migration
  def change
    add_column :best_guess_attempts, :value_in_credits, :integer
  end
end
