class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :credits
      t.decimal :price
      t.string :title
      t.string :image

      t.timestamps null: false
    end
  end
end
