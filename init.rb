require 'redmine'

#hooks
require 'datacenter_assets'
require 'datacenter_issue_hook'

#patches
require 'datacenter_ipaddr_patch'
config.to_prepare do
  require_dependency 'datacenter_issue_patch'
  require_dependency 'datacenter_issues_controller_patch'
  require_dependency 'datacenter_query_patch'
  require_dependency 'datacenter_project_patch'
  require_dependency 'datacenter_tabular_form_builder_patch'
end

#store ip addresses as integer
require 'acts_as_ipaddress'

Redmine::Plugin.register :datacenter_plugin do
  name 'Datacenter management plugin'
  author 'Jean-Baptiste BARTH'
  description 'This plugin helps you manage your (small) datacenter with redmine'
  url 'http://code.jbbarth.com/projects/redmine-datacenter/wiki'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.2.1'
  requires_redmine :version_or_higher => '0.9.0'
  
  menu :project_menu,
       :datacenter, { :controller => 'datacenters', :action => 'show' },
       :caption => :label_datacenter,
       :param => :project_id

  project_module :datacenter do
    permission :view_datacenter, {:datacenters => :show,
                                  :applis => [:index, :show, :update_servers],
                                  :instances => [:select_servers],
                                  :servers => [:index, :show],
                                  :networks => [:index, :overview, :show],
                                  :crontabs => [:index, :show]}
    permission :manage_datacenter, {:datacenters => [:new, :create, :edit, :update, :destroy],
                                    :applis => [:new, :create, :edit, :update, :destroy],
                                    :servers => [:new, :create, :edit, :update, :destroy],
                                    :instances => [:new, :create, :edit, :update, :destroy],
                                    :networks => [:new, :create, :edit, :update, :destroy]},
                                   :require => :member
    #set to public here, but there's a require_admin in the controller
    permission :admin_datacenter, {:datacenters => :index}, :public => true
  end
  
  settings :default => {
              'hide_admin_links' => false
            },
           :partial => 'settings/redmine_datacenter'
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :datacenters, {:controller => :datacenters}, :caption => :label_datacenter_plural
  menu.push :nested_lists, {:controller => :nested_lists}, :caption => :label_datacenter_list_plural
  #menu.push :servers, {:controller => :servers}, :caption => :label_server_plural
  #menu.push :applis, {:controller => :applis}, :caption => :label_appli_plural
end
