class CreatePrizeClaims < ActiveRecord::Migration
  def change
    create_table :prize_claims do |t|
      t.references :user, index: true, foreign_key: true
      t.references :target, polymorphic: true
      t.integer :status, default: 0
      t.string :full_name
      t.string :deliver_address
      t.string :phone_number
      t.date :shipped_on
      t.text :notes
      t.string :tracking_code

      t.timestamps null: false
    end
  end
end
