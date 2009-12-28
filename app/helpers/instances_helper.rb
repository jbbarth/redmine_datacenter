module InstancesHelper
  def change_link_instance_status(appli,instance)
    parameters = {:id => instance, :action => :update, :controller => :instances, :appli_id => appli.id}
    if instance.active?
      link_to l(:button_lock),
              url_for(:overwrite_params => parameters.merge(:instance => {:status => Instance::STATUS_LOCKED})),
              :method => :put,
              :class => 'icon icon-lock'
    else
      link_to l(:button_unlock),
              url_for(:overwrite_params => parameters.merge(:instance => {:status => Instance::STATUS_ACTIVE})),
              :method => :put,
              :class => 'icon icon-unlock'
    end
  end
end
