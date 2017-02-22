ActiveAdmin.register Auction do
  permit_params :title, :image, :description_url, :happens_at, :countdown_timer,
        :winner_id, :final_cost, :ended_at, :bid_cost_in_credits, :market_price,
        :happens_at_date, :happens_at_time_hour, :happens_at_time_minute,
        :description, :increase_value, :join_cost_in_credits, :tournament,
        :players, :credits_by_attempt, :second_image, :max_attempts

  before_update do |auction|
    if params[:auction][:reactivate] == "1"
      auction.ended_at = nil
    end
  end

  member_action :cancel, method: :patch do
    if resource.cancel
      redirect_to resource_path, notice: "Leilão cancelado com sucesso"
    else
      redirect_to resource_path, notice: "Não foi possível cancelar o leilão"
    end
  end

  action_item :view, only: :show do
    link_to 'Cancelar Leilão', cancel_admin_auction_path(auction), method: :patch, data: { confirm: "Você tem certeza? Não é possível desfazer essa ação." }
  end

  member_action :highlight, method: :patch do
    if Highlight.create!(target: resource).persisted?
      redirect_to admin_highlights_path, notice: "Leilão destacado com sucesso"
    else
      redirect_to resource_path, alert: "Não foi possível destacar o leilão. Destaque já existe?"
    end
  end

  action_item :view, only: :show do
    link_to 'Destacar Leilão', highlight_admin_auction_path(auction), method: :patch, data: { confirm: "Você tem certeza? Esse jogo será destacado." }
  end

  index do
    selectable_column
    id_column
    column :title
    column :happens_at
    column :bid_cost_in_credits
    column :winner
    column :ended_at
    column :canceled
    column :tournament
    column :players
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description do |auction|
        auction.description.try(:html_safe)
      end
      row :description_url do |auction|
        link_to auction.description_url, auction.description_url
      end
      row :image do |auction|
        image_tag auction.image
      end
      row :second_image do |auction|
        image_tag(auction.second_image.url) if auction.second_image?
      end
      row :happens_at
      row :countdown_timer
      row :bid_cost_in_credits
      row :market_price
      row :ended_at
      row :winner
      row :final_cost
      row :created_at
      row :updated_at
      row :canceled
      row :increase_value
      row :join_cost_in_credits
      row :tournament
      row :credits_by_attempt
      row :max_attempts

      panel 'Lances' do
        table_for auction.bids do
          column :id
          column :user
          column :value_in_credits
          column :created_at do |bid|
            I18n.l(bid.created_at, format: :all)
          end
        end
      end
    end
  end

  form do |f|
    inputs do
      input :title, input_html: { maxlength: 24 }
      input :image
      input :second_image
      input :description_url
      input :description, as: :wysihtml5, commands: [ :bold, :italic, :underline, :ul, :ol, :outdent, :indent, :link, :source ], blocks: []
      input :bid_cost_in_credits
      input :happens_at, as: :just_datetime_picker
      if f.object.finished? && !f.object.sold?
        input :reactivate, as: :boolean
      end
      input :countdown_timer
      input :market_price
      input :increase_value, hint: 'em centavos'
      input :tournament
      input :join_cost_in_credits
      input :credits_by_attempt
      input :players
      input :max_attempts
      li "#{f.object.class.human_attribute_name(:created_at)}: #{l f.object.created_at, format: :long}" if f.object.persisted?
    end
    actions
  end
end
