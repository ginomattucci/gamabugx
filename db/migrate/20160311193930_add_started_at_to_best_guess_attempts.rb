class AddStartedAtToBestGuessAttempts < ActiveRecord::Migration
  def change
    add_column :best_guess_attempts, :started_at, :datetime
  end
end
