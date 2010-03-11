module DatacentersHelper
  def datacenters_status_options_for_select(selected)
    datacenter_count_by_status = Datacenter.count(:group => 'status').to_hash
    options = [[l(:label_all), '']]
    [[:status_active,Datacenter::STATUS_ACTIVE],[:status_locked,Datacenter::STATUS_LOCKED]].each do |a|
      options << ["#{l(a[0])} (#{datacenter_count_by_status[a[1]].to_i})", a[1]]
    end
    options_for_select(options, selected)
  end

  def change_link_datacenter_status(datacenter)
    parameters = {:id => datacenter, :action => :update}
    if datacenter.active?
      link_to l(:button_lock),
              url_for(:overwrite_params => parameters.merge(:datacenter => {:status => Datacenter::STATUS_LOCKED})),
              :method => :put,
              :class => 'icon icon-lock'
    else
      link_to l(:button_unlock),
              url_for(:overwrite_params => parameters.merge(:datacenter => {:status => Datacenter::STATUS_ACTIVE})),
              :method => :put,
              :class => 'icon icon-unlock'
    end
  end

  def project_link(datacenter)
    if datacenter.active? && !datacenter.project.nil?
      link_to datacenter.project.name, {:controller => "projects", :action => "show", :id => datacenter.project.identifier}
    else
      "-"
    end
  end
  
  def datacenter_check_box(setting, checked=false, options={})
    hidden_field_tag("datacenter[options][#{setting}]", 0, :id => "datacenter_options_hidden_#{setting}") +
    check_box_tag("datacenter[options][#{setting}]", 1, checked, options)
  end

  def format_nagios_line(section)
    status = section[:status]
    title = link_to_if(section[:server].is_a?(Server),
                       section[:host_name],
                       :overwrite_params => { :controller => "servers",
                                              :action => "show",
                                              :id => section[:server] }
                      )
    title << ": " + section[:service_description] if section[:service_description]
    output = section[:plugin_output]
    if section[:type] == "servicestatus"
      html = %Q(<div class="nagios-#{status.downcase} nagios-service">)
    else
      html = %Q(<div class="nagios-#{status.downcase} nagios-host-#{status.downcase}">)
    end
    html << "#{title}<br />"
    html << %Q(<span class="infos">#{output}</span>) unless output.blank?
    html << "</div>"
  end
end
