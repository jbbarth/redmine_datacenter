class DatacentersController < DatacenterPluginController
  unloadable

  before_filter :find_project, :authorize, :except => :index
  before_filter :find_datacenter, :except => [:index, :new, :create]
  before_filter :require_admin, :only => :index

  #no pagination or such things here
  #if you have more than 20 datacenters, you're too big for this plugin :)

  def index
    # admin part, not scoped under a specific project
    @status = params[:status] ? params[:status].to_i : Datacenter::STATUS_ACTIVE
    @datacenters = Datacenter.all(:conditions => (@status == 0 ? nil : ["status = ?", @status]))
  end

  def show
    #activity boxes
    @activity = @datacenter.fetch_activity(
                  :user => User.current,
                  :types => %w(issues wiki_edits changesets),
                  :limit => 3
                )      
    #nagios integration
    if @datacenter.tool_enabled?(:nagios)
      nagios_file = @datacenter.nagios_file
      begin
        @nagios_status = Nagios::Status.new(nagios_file)
      rescue Errno::ENOENT
        flash.now[:error] = "#{nagios_file}: no such file or directory"
      end
    end

    #storage integration
    if @datacenter.tool_enabled?(:storage)
      @storage_devices = @datacenter.storage_files.map do |file|
        Storage::Bay.new(File.basename(file), :profile => file)
      end
    end
  end
  
  def new
    @datacenter = Datacenter.new
  end
  
  def create
    @datacenter = Datacenter.new(params[:datacenter])
    if @datacenter.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'show', :project_id => @project
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @datacenter.update_attributes(params[:datacenter])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'show', :project_id => @project
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @datacenter.status = Datacenter::STATUS_LOCKED
    @datacenter.save
    redirect_to :action => 'show', :project_id => @project
  end
end
