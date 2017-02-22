class AddFieldsToPrizeClaims < ActiveRecord::Migration
  def change
    add_column :prize_claims, :cpf, :string
    add_column :prize_claims, :neighborhood, :string
    add_column :prize_claims, :city, :string
    add_column :prize_claims, :uf, :string
    add_column :prize_claims, :country, :string
    add_column :prize_claims, :zip_code, :string
  end
end
