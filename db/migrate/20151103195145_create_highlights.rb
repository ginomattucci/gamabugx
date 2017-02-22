class CreateHighlights < ActiveRecord::Migration
  def change
    create_table :highlights do |t|
      t.references :target, polymorphic: true

      t.timestamps null: false
    end
  end
end
