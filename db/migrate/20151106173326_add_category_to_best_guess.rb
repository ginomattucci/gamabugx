class AddCategoryToBestGuess < ActiveRecord::Migration
  def change
    add_column :best_guesses, :category, :string
  end
end
