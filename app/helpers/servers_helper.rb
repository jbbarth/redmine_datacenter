module ServersHelper
  def servers_status_options_for_select(selected)
    server_count_by_status = Server.count(:group => 'status').to_hash
    options = [[l(:label_all), '']]
    [[:status_active,Server::STATUS_ACTIVE],[:status_locked,Server::STATUS_LOCKED]].each do |a|
      options << ["#{l(a[0])} (#{server_count_by_status[a[1]].to_i})", a[1]]
    end
    options_for_select(options, selected)
  end

  def change_link_server_status(server)
    url = {:controller => 'servers', :action => 'update', :id => server, :page => params[:page], :status => params[:status], :tab => nil}
    if server.active?
      link_to l(:button_lock), url_for(:overwrite_params => {:id => server, 
                                                              :server => {:status => Server::STATUS_LOCKED}
                                      }), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url_for(:overwrite_params => {:id => server,
                                                              :server => {:status => Server::STATUS_ACTIVE}
                                        }), :method => :put, :class => 'icon icon-unlock'
    end
  end
end
