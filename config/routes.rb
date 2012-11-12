RedmineApp::Application.routes.draw do
  resources :nested_lists do
    collection{ put :rebuild }
  end
  scope 'projects/:project_id' do
    resource  :datacenters
    resources :servers
    resources :applis do
      resources :instances do
        collection { get :select_servers }
      end
    end
    resources :networks do
      collection { get :overview }
    end
    resources :crontabs, :only => [:index, :show]
    resources :apaches, :only => [:index, :show] do
      member { get :browse }
    end
  end
end
