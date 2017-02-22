ActiveAdmin.register User do
  permit_params :email, :username, :credits, :blocked

  actions :all, except: [:new, :create]

  index do
    id_column
    column :email
    column :username
    column :blocked
    column :credits
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :address
      row :cpf
      row :document_id
      row :credits
      row :blocked
      row :phone
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs do
      input :email
      input :username
      input :credits
      input :address
      input :cpf
      input :document_id
      input :credits
      input :phone
      input :blocked
      li "#{f.object.class.human_attribute_name(:created_at)}: #{l f.object.created_at, format: :long}" if f.object.persisted?
    end
    actions
  end
end
