ActiveAdmin.register BestGuess do
  permit_params :title, :image, :description_url, :happens_at, :ends_at, :category,
  :question, :join_cost_in_credits, :market_price, :happens_at_date,
  :happens_at_time_hour, :happens_at_time_minute, :ends_at_date, :second_image,
  :ends_at_time_hour, :ends_at_time_minute, :description, :increase_value,
  :tournament, :players, :duration_time,
  statements_attributes: [:id, :content, :answer, :image, :_destroy]

  member_action :highlight, method: :patch do
    if Highlight.create(target: resource).persisted?
      redirect_to admin_highlights_path, notice: "Super Palpite destacado com sucesso"
    else
      redirect_to resource_path, alert: "Não foi possível destacar o Super Palpite. Destaque já existe?"
    end
  end

  action_item :view, only: :show do
    link_to 'Destacar Super Palpite', highlight_admin_best_guess_path(best_guess), method: :patch, data: { confirm: "Você tem certeza? Esse jogo será destacado." }
  end

  index do
    selectable_column
    id_column
    column :title
    column :tournament
    column :happens_at
    column :ends_at
    column :join_cost_in_credits
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :question
      row :description_url do |best_guess|
        link_to best_guess.description_url, best_guess.description_url
      end
      row :description do |best_guess|
        best_guess.description.html_safe
      end
      row :image do |best_guess|
        image_tag best_guess.image
      end
      row :second_image do |best_guess|
        image_tag(best_guess.second_image.url) if best_guess.second_image?
      end
      row :happens_at
      row :ends_at
      row :join_cost_in_credits
      row :market_price
      row :winner
      row :category
      row :created_at
      row :updated_at
      row :increase_value
      row :tournament
      row :players
      row :duration_time
    end
    panel 'Respostas' do
      table_for best_guess.statements do
        column :id
        column :content
        column :answer
        column :image do |statement|
          link_to statement.image.url, statement.image.url, target: :blank if statement.image.present?
        end
      end
    end

    panel 'Participantes' do
      table_for best_guess.best_guess_attempts do
        column :id
        column :user
        column :score
        column :created_at
        column :started_at
        column :finished_at
        column 'Tempo total' do |attempt|
          if attempt.finish_time
            time = Time.at(attempt.finish_time).utc.strftime("%Mm %Ss %3Nms")
            "#{time} (#{attempt.finish_time})"
          end
        end
      end
    end
  end

  form do |f|
    inputs do
      input :title, input_html: { maxlength: 24 }
      input :question
      input :image
      input :second_image
      input :description_url
      input :description, as: :wysihtml5, commands: [ :bold, :italic, :underline, :ul, :ol, :outdent, :indent, :link, :source ], blocks: []
      input :happens_at, as: :just_datetime_picker
      input :ends_at, as: :just_datetime_picker
      input :join_cost_in_credits
      input :market_price
      input :category
      input :tournament
      input :players
      input :duration_time
      input :increase_value, hint: 'em centavos'
      has_many :statements, allow_destroy: true do |a|
        a.input :content, as: :string
        a.input :answer, as: :select, collection: [['Verdadeira', true], ['Falsa', false]], include_blank: false
        a.input :image
      end
      li "#{f.object.class.human_attribute_name(:created_at)}: #{l f.object.created_at, format: :long}" if f.object.persisted?
    end
    actions
  end
end
