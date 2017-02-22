class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.string :title
      t.string :image
      t.string :description_url
      t.datetime :happens_at
      t.integer :countdown_timer, default: 10
      t.references :winner
      t.decimal :final_cost
      t.datetime :ended_at
      t.integer :bid_cost_in_credits, default: 1

      t.timestamps null: false
    end
  end
end
