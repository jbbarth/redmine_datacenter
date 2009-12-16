class DatacenterController < ApplicationController
  before_filter :require_admin
  before_filter :retrieve_settings

  unloadable

  helper :sort
  include SortHelper
  
  private
  def retrieve_settings
    @settings = Setting["plugin_datacenter_plugin"]
  end
end
