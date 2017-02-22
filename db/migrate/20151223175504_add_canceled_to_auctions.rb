class AddCanceledToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :canceled, :boolean, default: false
  end
end
