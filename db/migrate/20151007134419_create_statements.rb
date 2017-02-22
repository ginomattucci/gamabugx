class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.references :best_guess, index: true, foreign_key: true
      t.text :content
      t.string :image
      t.boolean :answer

      t.timestamps null: false
    end
  end
end
