class AddSecondImageToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :second_image, :string
  end
end
