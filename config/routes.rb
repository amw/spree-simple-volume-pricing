Rails.application.routes.draw do
  namespace :admin do
    resources :products, :only => [] do
      get :volume_prices, :on => :member
    end
  end
end
