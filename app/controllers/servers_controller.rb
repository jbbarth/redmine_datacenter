class ServersController < DatacenterPluginController
  before_filter :find_server, :only => [:show, :edit, :update, :destroy]
  unloadable

  def index
    sort_init 'name', 'asc'
    sort_update %w(servers.name fqdn description interfaces.ipaddress)
    
    @status = params[:status] ? params[:status].to_i : Server::STATUS_ACTIVE
    c = ARCondition.new(["datacenter_id = ?", @datacenter.id])
    c << ["servers.status = ?", @status] unless @status == 0
    c << ["LOWER(servers.name) LIKE ?", params[:name].strip.downcase] unless params[:name].blank?

    joins = ["LEFT JOIN interfaces_servers ON interfaces_servers.server_id = servers.id",
             "LEFT JOIN interfaces ON interfaces_servers.interface_id = interfaces.id"]  
    @server_count = Server.count(:conditions => c.conditions, :joins => joins)
    @server_pages = Paginator.new self, @server_count,
                per_page_option,
                params['page']

    @servers =  Server.all :select => "servers.*, interfaces.ipaddress",
                           :conditions => c.conditions, 
                           :order => sort_clause, 
                           :limit  =>  @server_pages.items_per_page, 
                           :offset =>  @server_pages.current.offset,
                           :joins => joins

    render :layout => !request.xhr?
  end
  
  def show
    c = ARCondition.new(["issues_servers.server_id = ?", @server.id])
    sort_init([['id', 'desc']])
    sort_update({'id' => "#{Issue.table_name}.id"})
    @issue_count = Issue.count(:joins => :servers, :conditions => c.conditions)
    @issue_pages = Paginator.new self, @issue_count, per_page_option, params['page']
    @issues = Issue.all :order => 'id desc',
                        :joins => :servers,
                        :conditions => c.conditions,
                        :limit => @issue_pages.items_per_page,
                        :offset => @issue_pages.current.offset,
                        :order => sort_clause
    render :layout => !request.xhr?
  end

  def new
    @server = Server.new
    @server.interfaces.build
  end
  
  def create
    unless params[:server].blank? || @datacenter.domain.blank?
      params[:server][:fqdn] ||= params[:server][:name]+@datacenter.domain
    end
    @server = Server.new(params[:server])
    if @server.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to server_path(@project,@server)
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    params[:server][:existing_interface_attributes] ||= {}
    if @server.update_attributes(params[:server])
      flash[:notice] = l(:notice_successful_update)
      redirect_to server_path(@project,@server)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @server.status = Server::STATUS_LOCKED
    @server.save
    redirect_to servers_url(:project_id => @project)
  end
  
  private
  def find_server
    begin
      @server = Server.find(params[:id],
                          :conditions => {:datacenter_id => @datacenter},
                          :include => :issues)
      @instances = @server.instances.active
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
