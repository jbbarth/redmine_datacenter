ActionController::Routing::Routes.draw do |map|
  map.resources :servers, :path_prefix => 'datacenter'
  map.resources :applis, :path_prefix => 'datacenter' do |appli|
    appli.resources :instance, :controller => 'instances' do |instance|
      instance.resources :servers
    end
  end
  map.resources :datacenters, :path_prefix => 'datacenter'
end
