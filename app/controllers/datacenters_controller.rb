class DatacentersController < DatacenterPluginController
  unloadable

  #no pagination or such things here
  #if you have more than 20 datacenters, you're too big for this plugin :)

  def index
    # admin part, not scoped under a specific project
    @status = params[:status] ? params[:status].to_i : Datacenter::STATUS_ACTIVE
    @datacenters = Datacenter.all(:conditions => (@status == 0 ? nil : ["status = ?", @status]))
  end

  def show
    @datacenter = @project.datacenter
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
    @datacenter = @project.datacenter
  end
  
  def update
    @datacenter = @project.datacenter
    if @datacenter.update_attributes(params[:datacenter])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'show', :project_id => @project
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @datacenter = @project.datacenter
    @datacenter.status = Datacenter::STATUS_LOCKED
    @datacenter.save
    redirect_to :action => 'show', :project_id => @project
  end
end
