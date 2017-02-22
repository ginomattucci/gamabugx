class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :image
      t.string :url
      t.string :title

      t.timestamps null: false
    end
  end
end
