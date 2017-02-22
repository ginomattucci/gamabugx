class AddDefaultToFinalCostOnAuctions < ActiveRecord::Migration
  def change
    change_column :auctions, :final_cost, :decimal, default: 0
  end
end
