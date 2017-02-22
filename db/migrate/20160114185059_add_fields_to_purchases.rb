class AddFieldsToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :fullname, :string
    add_column :purchases, :cpf, :string
    add_column :purchases, :address, :string
    add_column :purchases, :neighborhood, :string
    add_column :purchases, :city, :string
    add_column :purchases, :uf, :string
    add_column :purchases, :country, :string
    add_column :purchases, :zip_code, :string
    add_column :purchases, :phone, :string
  end
end
