require 'redmine'

#hooks
require 'datacenter_assets'
require 'add_servers_to_issue_form'

#patches
config.to_prepare do
  require_dependency 'issue_patch'
  require_dependency 'issues_controller_patch'
end

Redmine::Plugin.register :datacenter_plugin do
  name 'Datacenter management plugin'
  author 'Jean-Baptiste BARTH'
  description 'This plugin helps you manage your (small) datacenter with redmine'
  url 'http://github.com/jbbarth/redmine_datacenter'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.1'
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :servers, :servers, :caption => :label_server_plural
end
