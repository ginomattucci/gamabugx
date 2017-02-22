class AddDescriptionToAuction < ActiveRecord::Migration
  def change
    add_column :auctions, :description, :text
  end
end
