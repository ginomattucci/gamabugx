class CreateBestGuesses < ActiveRecord::Migration
  def change
    create_table :best_guesses do |t|
      t.string :title
      t.datetime :happens_at
      t.datetime :ends_at
      t.string :image
      t.string :description_url
      t.integer :join_cost_in_credits, default: 10
      t.references :winner, index: true
      t.text :question

      t.timestamps null: false
    end
  end
end
