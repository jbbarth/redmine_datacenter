class ServersController < ApplicationController
  unloadable

  helper :sort
  include SortHelper

  def index
    sort_init 'name', 'asc'
    sort_update %w(name fqdn ipaddress)
    
    @server_count = Server.count
    @server_pages = Paginator.new self, @server_count,
                per_page_option,
                params['page']
    @servers =  Server.all :order => sort_clause,
            :limit  =>  @server_pages.items_per_page,
            :offset =>  @server_pages.current.offset

    render :layout => !request.xhr?
  end
  
  def new
    @server = Server.new
  end
  
  def create
    @server = Server.new(params[:server])
    if @server.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to servers_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @server = Server.find(params[:id])
  end
  
  def update
    @server = Server.find(params[:id])
    if @server.update_attributes(params[:server])
      flash[:notice] = l(:notice_successful_update)
      redirect_to servers_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @server = Server.find(params[:id])
    @server.destroy
    #flash[:notice] = "Successfully destroyed server."
    redirect_to servers_url
  end
end
