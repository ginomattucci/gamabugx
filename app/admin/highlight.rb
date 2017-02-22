ActiveAdmin.register Highlight do
  permit_params :target_type, :target_id
  actions :index, :destroy

  index do
    id_column
    column :target
    column :updated_at
    column :created_at
    actions
  end
end
