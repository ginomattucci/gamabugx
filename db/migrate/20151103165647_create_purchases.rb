class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.references :plan, index: true, foreign_key: false
      t.references :user, index: true, foreign_key: true
      t.string :plan_name
      t.integer :plan_credits
      t.decimal :plan_price
      t.string :status
      t.string :invoice
      t.string :invoice_url
      t.string :payment_method

      t.timestamps null: false
    end
  end
end
