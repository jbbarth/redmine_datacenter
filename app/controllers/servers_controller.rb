class ServersController < DatacenterPluginController
  unloadable

  def index
    sort_init 'name', 'asc'
    sort_update %w(name fqdn description)
    
    @status = params[:status] ? params[:status].to_i : Server::STATUS_ACTIVE
    c = ARCondition.new(["datacenter_id = ?", @project.datacenter.id])
    c << ["status = ?", @status] unless @status == 0
    
    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      c << ["LOWER(name) LIKE ?", name]
    end
    
    @server_count = Server.count(:conditions => c.conditions)
    @server_pages = Paginator.new self, @server_count,
                per_page_option,
                params['page']
    @servers =  Server.all :order => sort_clause,
            :conditions => c.conditions,
            :limit  =>  @server_pages.items_per_page,
            :offset =>  @server_pages.current.offset

    render :layout => !request.xhr?
  end
  
  def show
    @server = Server.find(params[:id], :include => :issues)
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
    unless params[:server].blank? || @project.datacenter.domain.blank?
      params[:server][:fqdn] ||= params[:server][:name]+@project.datacenter.domain
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
    @server = Server.find(params[:id])
  end
  
  def update
    params[:server][:existing_interface_attributes] ||= {}
    @server = Server.find(params[:id])
    if @server.update_attributes(params[:server])
      flash[:notice] = l(:notice_successful_update)
      redirect_to server_path(@project,@server)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @server = Server.find(params[:id])
    @server.status = Server::STATUS_LOCKED
    @server.save
    redirect_to servers_url(:project_id => @project)
  end
end
