module ServersHelper
  def servers_status_options_for_select(selected, datacenter)
    server_count_by_status = Server.count(:conditions => ["datacenter_id = ?", datacenter], :group => 'status').to_hash
    options = [[l(:label_all), '']]
    [[:status_active,Server::STATUS_ACTIVE],[:status_locked,Server::STATUS_LOCKED]].each do |a|
      options << ["#{l(a[0])} (#{server_count_by_status[a[1]].to_i})", a[1]]
    end
    options_for_select(options, selected)
  end

  def change_link_server_status(server)
    parameters = {:id => server, :action => :update}
    if server.active?
      link_to l(:button_lock),
              url_for(parameters.merge(:server => {:status => Server::STATUS_LOCKED})),
              :method => :put,
              :class => 'icon icon-lock'
    else
      link_to l(:button_unlock),
              url_for(parameters.merge(:server => {:status => Server::STATUS_ACTIVE})),
              :method => :put,
              :class => 'icon icon-unlock'
    end
  end
  
  def add_interface_link(name,f)
    fields = f.fields_for(:interfaces, Interface.new) do |builder|
      render("interface_fields", :f => builder)
    end
    link_to_function name, :id => 'add_interface', :class => 'icon icon-add' do |page|
      page.insert_html :before, :add_interface, fields
    end
  end
  
  def links_to_servers(project,servers)
    servers.sort_by(&:name).map do |server|
      link_to(server.name, server_path(project,server))
    end.join(", ").html_safe
  end
end
