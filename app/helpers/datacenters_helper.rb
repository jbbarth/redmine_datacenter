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
end
