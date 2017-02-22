ActiveAdmin.register Plan do
  permit_params :credits, :price, :title, :image, :image_cache

  show do
    attributes_table do
      row :title
      row :credits
      row :price do
        number_to_currency plan.price
      end
      row :image do
        image_tag plan.image.url if plan.image?
      end
      row :created_at
      row :updated_at
    end
  end
end
