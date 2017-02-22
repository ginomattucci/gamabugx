class AddCityCountryFullnameNeighborhoodPhoneUfAndZipCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :fullname, :string
    add_column :users, :neighborhood, :string
    add_column :users, :phone, :string
    add_column :users, :uf, :string
    add_column :users, :zip_code, :string
  end
end
