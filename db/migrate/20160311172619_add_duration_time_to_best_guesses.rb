class AddDurationTimeToBestGuesses < ActiveRecord::Migration
  def change
    add_column :best_guesses, :duration_time, :integer
  end
end
