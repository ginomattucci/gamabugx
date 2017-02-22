ActiveAdmin.register Banner do
  permit_params :title, :image, :url

  filter :title
  filter :url
  filter :created_at
  filter :updated_at

  index do
    id_column
    column :title
    column :image do |banner|
      link_to 'Clique para ver', banner.image.url, target: :blank
    end
    column :url do |banner|
      link_to banner.url, banner.url, target: :blank
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :url do |banner|
        link_to banner.url, banner.url
      end
      row :image do |banner|
        image_tag banner.image
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs do
      input :title
      input :image
      input :url
      li "#{f.object.class.human_attribute_name(:created_at)}: #{l f.object.created_at, format: :long}" if f.object.persisted?
    end
    actions
  end
end
