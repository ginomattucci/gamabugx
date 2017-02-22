ActiveAdmin.register PrizeClaim do
  permit_params :status, :shipped_on, :notes, :tracking_code, :shipped_on_date,
    :shipped_on_time_hour, :shipped_on_time_minute, :cpf, :neighborhood, :city,
    :uf, :country, :zip_code

  actions :all, except: [:new, :create]

  controller do
    def update
      resource.skip_days = true
      super
    end
  end

  index do
    id_column
    column :user
    column :target
    column :status do |prize_claim|
      prize_claim.status_humanize
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :target
      row :status do |prize_claim|
        prize_claim.status_humanize
      end
      row :full_name
      row :deliver_address
      row :phone_number
      row :shipped_on
      row :notes
      row :tracking_code
      row :cpf
      row :neighborhood
      row :city
      row :uf
      row :country
      row :zip_code
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    inputs do
      input :status, collection: PrizeClaimStatus.to_a, as: :select, include_blank: false
      input :shipped_on, as: :just_datetime_picker
      input :notes
      input :tracking_code
      input :cpf
      input :neighborhood
      input :city
      input :uf
      input :country
      input :zip_code
      li "#{f.object.class.human_attribute_name(:created_at)}: #{l f.object.created_at, format: :long}" if f.object.persisted?
    end
    actions
  end
end
