require 'redmine'

#hooks
require 'datacenter_assets'
require 'datacenter_issue_hook'

#patches
config.to_prepare do
  require_dependency 'issue_patch'
  require_dependency 'issues_controller_patch'
  require_dependency 'setting_patch'
  require_dependency 'query_patch'
  require_dependency 'project_patch'
end

Redmine::Plugin.register :datacenter_plugin do
  name 'Datacenter management plugin'
  author 'Jean-Baptiste BARTH'
  description 'This plugin helps you manage your (small) datacenter with redmine'
  url 'http://code.jbbarth.com/projects/redmine-datacenter/wiki'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.1'
  requires_redmine :version_or_higher => '0.9.0'
  
  menu :project_menu,
       :datacenter, { :controller => 'datacenters', :action => 'show' },
       :caption => :label_datacenter,
       :param => :project_id

  project_module :datacenter do
    permission :dummy_datacenter_permission, {}, :public => true
    permission :dummy2_datacenter_permission, {:datacenters=>[:show]}, :public => true
  end
  
  settings :default => {
              'multiple_select' => "1", #false=checkboxes, true=multiple_select
              'domain'          => ""
            },
           :partial => 'settings/redmine_datacenter'
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :datacenters, {:controller => :datacenters}, :caption => :label_datacenter_plural
  #menu.push :servers, {:controller => :servers}, :caption => :label_server_plural
  #menu.push :applis, {:controller => :applis}, :caption => :label_appli_plural
end
