class AddSecondImageToBestGuesses < ActiveRecord::Migration
  def change
    add_column :best_guesses, :second_image, :string
  end
end
