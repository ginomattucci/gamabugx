class AddDescriptionToBestGuess < ActiveRecord::Migration
  def change
    add_column :best_guesses, :description, :text
  end
end
