class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address, :string
    add_column :users, :cpf, :string
    add_column :users, :document_id, :string
  end
end
