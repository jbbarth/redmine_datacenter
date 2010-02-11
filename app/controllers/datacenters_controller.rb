class DatacentersController < DatacenterPluginController
  unloadable

  #no pagination or such things here
  #if you have more than 20 datacenters, you're too big for this plugin :)

  def index
    @status = params[:status] ? params[:status].to_i : Datacenter::STATUS_ACTIVE
    c = ARCondition.new(@status == 0 ? nil : ["status = ?", @status])
    @datacenters =  Datacenter.all :conditions => c.conditions
  end
  
  def show
    @datacenter = Datacenter.find(params[:id])
  end
  
  def new
    @datacenter = Datacenter.new
    @projects = Project.all
  end
  
  def create
    @datacenter = Datacenter.new(params[:datacenter])
    if @datacenter.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to @datacenter
    else
      render :action => 'new'
    end
  end
  
  def edit
    @datacenter = Datacenter.find(params[:id])
    @projects = Project.all
  end
  
  def update
    @datacenter = Datacenter.find(params[:id])
    if @datacenter.update_attributes(params[:datacenter])
      flash[:notice] = l(:notice_successful_create)
      redirect_to @datacenter
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @datacenter = Datacenter.find(params[:id])
    @datacenter.status = Datacenter::STATUS_LOCKED
    @datacenter.save
    redirect_to :action => 'index'
  end
end
