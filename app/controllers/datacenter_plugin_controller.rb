class DatacenterPluginController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
  before_filter :retrieve_settings
  before_filter :retrieve_plugin, :only => :index

  unloadable

  helper :sort
  include SortHelper

  layout 'admin'
  
  private
  def retrieve_settings
    @settings = Setting["plugin_datacenter_plugin"]
  end

  def retrieve_plugin
    @plugin = Redmine::Plugin.find(:datacenter_plugin)
  end
end
