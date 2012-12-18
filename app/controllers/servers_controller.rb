class ServersController < DatacenterPluginController
  before_filter :find_server, :only => [:show, :edit, :update, :destroy]
  before_filter :find_hypervisors, :only => [:new, :create, :edit, :update]
  unloadable

  helper :datacenters

  def index
    sort_init 'servers.name', 'asc'
    sort_update %w(servers.name description interfaces.ipaddress hypervisors.name operating_systems.name)
    @status = params[:status] ? params[:status].to_i : Server::STATUS_ACTIVE
    servers = Server.where("servers.datacenter_id = ?", @datacenter.id)
    servers = servers.where("servers.status = ?", @status) unless @status == 0
    servers = servers.where("LOWER(servers.name) LIKE ?", "%#{params[:name].strip.downcase}%") unless params[:name].blank?
    servers = servers.joins(["LEFT JOIN servers AS hypervisors ON servers.hypervisor_id = hypervisors.id",
                             "LEFT JOIN operating_systems ON operating_systems.id = servers.operating_system_id",
                             "LEFT JOIN interfaces_servers ON interfaces_servers.server_id = servers.id",
                             "LEFT JOIN interfaces ON interfaces_servers.interface_id = interfaces.id"])
    @server_count = servers.count
    @server_pages = Paginator.new self, @server_count, per_page_option, params['page']

    @servers =  servers.select("servers.*, interfaces.ipaddress")
                       .limit(@server_pages.items_per_page) 
                       .offset(@server_pages.current.offset)
                       .order(sort_clause)
    
    render :layout => !request.xhr?
  end
  
  def show
    sort_init([['id', 'desc']])
    sort_update({'id' => "#{Issue.table_name}.id"})
    issues = Issue.where("issues_servers.server_id = ?", @server.id)
                  .joins(:servers)
    @issue_count = issues.count
    @issue_pages = Paginator.new self, @issue_count, per_page_option, params['page']
    @issues = issues.limit(@issue_pages.items_per_page)
                    .offset(@issue_pages.current.offset)
                    .order(sort_clause)
    if @datacenter.tool_enabled?(:nagios)
      begin
        @nagios_status = Nagios::Status.new(@datacenter.nagios_file,
                                            :scope => lambda{|s|s.include?("host_name=#{@server.name}")},
                                            :include_ok => true)
      rescue Errno::ENOENT
        #nothing, there's already a warning message on datacenters/show page
      end
    end
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
      @server = Server.includes(:issues)
                      .where(:datacenter_id => @datacenter)
                      .find(params[:id])
      @instances = @server.instances.active
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  def find_hypervisors
    @hypervisors = Server.hypervisors.where("datacenter_id = ? AND servers.id != ? AND hypervisor_id is null",
                                            @datacenter.id,
                                            @server.try(:id).to_i)
                                     .order("servers.name")
  end
end
