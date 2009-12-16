ActionController::Routing::Routes.draw do |map|
  map.resources :servers, :path_prefix => 'datacenter'
  map.resources :applis, :path_prefix => 'datacenter'
end
