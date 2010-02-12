class DatacenterPluginController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
  before_filter :retrieve_settings
  before_filter :retrieve_plugin
  before_filter :find_project, :set_menu_item

  unloadable

  helper :sort
  include SortHelper

  layout :set_layout

  private
  def retrieve_settings
    @settings = Setting["plugin_datacenter_plugin"]
  end

  def retrieve_plugin
    @plugin = Redmine::Plugin.find(:datacenter_plugin)
  end

  def find_project
    @project = begin
                 Project.find(params[:project_id])
               rescue
                 #nothing, we just want nil instead of NotFound exception
                 #find_by_id would have been great but Redmine passes the
                 #aphabetical identifier in most links, not the ID
               end
  end

  def set_layout
    @project ? "datacenter" : "admin"
  end
  
  #better than simple "menu_item" call because 
  #"menu_item" is not inherited in sub-controllers
  def set_menu_item
    self.class.menu_item :datacenter if @project
  end
end
