ActionController::Routing::Routes.draw do |map|
  #map.resources :servers, :path_prefix => 'datacenter'
  #map.resources :applis, :path_prefix => 'datacenter' do |appli|
  #  appli.resources :instance, :controller => 'instances' do |instance|
  #    instance.resources :servers
  #  end
  #end
  #map.resources :datacenters, :path_prefix => 'datacenter'
  map.resources :nested_lists
  map.with_options :path_prefix => 'projects/:project_id' do |mmap|
    mmap.resource  :datacenter
    mmap.datacenters 'datacenters', :controller => 'datacenters'
    mmap.resources :servers
    mmap.resources :applis do |appli|
      appli.resources :instance, :controller => 'instances' do |instance|
        instance.resources :servers, :collection => {:select_servers => :get}
      end
    end
    mmap.resources :networks, :collection => {:overview => :get}
  end
end
