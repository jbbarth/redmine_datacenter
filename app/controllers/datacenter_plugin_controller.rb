class DatacenterPluginController < ApplicationController
  before_filter :find_project, :find_datacenter, :authorize
  before_filter :retrieve_settings, :set_menu_item

  unloadable

  helper :sort
  include SortHelper

  layout :set_layout

  private
  def retrieve_settings
    @settings = Setting["plugin_redmine_datacenter"]
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_datacenter
    @datacenter = @project.datacenter
    if @datacenter.nil?
      redirect_to(:controller => :datacenters, :action => :new, :project_id => @project) && return
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
