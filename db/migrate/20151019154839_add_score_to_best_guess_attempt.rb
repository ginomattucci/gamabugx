class AddScoreToBestGuessAttempt < ActiveRecord::Migration
  def change
    add_column :best_guess_attempts, :score, :integer, default: 0
  end
end
