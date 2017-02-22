Rails.application.routes.draw do
  root 'pages#home'

  get '/busca', to: 'search#games', as: 'search'

  scope path_names: { new: 'novo', edit: 'editar' } do
    get '/auctions/finished', to: 'games#finished_auctions', as: 'finished_auctions', path: 'clicks/finalizados'
    get '/auctions/scheduled', to: 'games#scheduled_auctions', as: 'scheduled_auctions', path: 'clicks/agendados'

    resources :auctions, only: %i(show), path: 'clicks' do
      get :verify_status
      resources :auction_bids, only: %i(create), as: :bids
      get '/prize_claim', to: 'prize_claims#new', as: 'prize_claim', path: 'reivindicar'
    end

    get '/best_guesses/finished', to: 'games#finished_best_guesses', as: 'finished_best_guesses', path: 'super-palpites/finalizados'
    get '/best_guesses/scheduled', to: 'games#scheduled_best_guesses', as: 'scheduled_best_guesses', path: 'super-palpites/agendados'
    get '/super-palpites', to: 'games#best_guesses', as: :best_guesses
    get '/torneio-palpites', to: 'games#best_guess_tournaments', as: :best_guess_tournaments
    get '/super-clicks', to: 'games#auctions', as: :auctions
    get '/torneio-clicks', to: 'games#auction_tournaments', as: :auction_tournaments
    resources :auction_attempts, only: :destroy

    resources :best_guesses, only: %i(show), path: 'super-palpites' do
      get :feedback
      get :unfinished_attempt_redirect
      get :verify_status
      resources :best_guess_attempt, only: %i(create edit update destroy), path: 'tentativas', as: :attempts
      get '/prize_claim', to: 'prize_claims#new', as: 'prize_claim', path: 'reivindicar'
    end

    resources :games, only: :index, path: 'jogos'

    resources :prize_claims, only: %i(create index), as: :prize_claims, path: 'premios'

    if Rails.env.development? || Rails.env.staging?
      get '/styleguide', to: 'pages#styleguide'
    end

    get '/termos', to: 'pages#terms', as: 'terms'
    get '/como-funciona', to: 'pages#how_it_works', as: 'how_it_works'
    get '/contato', to: 'pages#contact', as: 'contact'
    post '/contato', to: 'pages#send_contact', as: nil

    resources :plans, only: %i(index), path: 'planos'
    resources :checkouts, only: %i(new create), path: 'comprar' do
      get :success, path: 'sucesso'
    end
    post "iugu/#{Rails.application.secrets.iugu_url}/notification", to: 'plans#notification', as: nil
    resources :purchases, only: %i(index), path: 'compras'

    devise_for :users, path: "usuarios", path_names: { sign_in: 'entrar', sign_out: 'sair', password: 'senha', registration: 'registro', sign_up: 'cadastro' }, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
    devise_scope :user do
      get '/mudar-senha', to: 'users/registrations#edit', as: :change_password
    end
  end
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
