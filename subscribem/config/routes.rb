Subscribem::Engine.routes.draw do
  require "subscribem/constraints/subdomain_required"

  constraints(Subscribem::Constraints::SubdomainRequired) do
    scope module: "account" do
      root to: "dashboard#index", as: :account_root
      get "/sign_in", to: "sessions#new", as: :sign_in
      post "/sign_in", :to => "sessions#create", as: :sessions
      get "/sign_up", to: "users#new", as: :user_sign_up
      post "/sign_up", to: "users#create", as: :do_user_sign_up
      get "/account", to: "accounts#edit", as: :edit_account
      patch "/account", to: "accounts#update"
      get "/account/plan/:plan_id", to: "accounts#plan", as: :plan_account
      get "/account/subscribe",
          to: "accounts#subscribe",
          as: :subscribe_account
    end
  end
  root "dashboard#index"
  get "/sign_up", :to => "accounts#new", :as => :sign_up
  post "/accounts", :to => "accounts#create", :as => :accounts

end

