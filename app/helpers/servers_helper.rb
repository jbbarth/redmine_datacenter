module ServersHelper
  def servers_status_options_for_select(selected)
    server_count_by_status = Server.count(:group => 'status').to_hash
    options = [[l(:label_all), '']]
    [[:status_active,Server::STATUS_ACTIVE],[:status_locked,Server::STATUS_LOCKED]].each do |a|
      options << ["#{l(a[0])} (#{server_count_by_status[a[1]].to_i})", a[1]]
    end
    options_for_select(options, selected)
  end
end
