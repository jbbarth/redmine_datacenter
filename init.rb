require 'redmine'

Redmine::Plugin.register :datacenter_plugin do
  name 'Datacenter management plugin'
  author 'Jean-Baptiste BARTH'
  description 'This plugin helps you manage your (small) datacenter with redmine'
  url 'http://github.com/jbbarth/redmine_datacenter'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.1'
end
