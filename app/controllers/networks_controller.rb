class NetworksController < DatacenterPluginController
  unloadable

  def index
    @networks = @project.datacenter.networks
  end
  
  def show
    @network = Network.find(params[:id])
  end
  
  def new
    @network = Network.new
  end
  
  def create
    @network = Network.new(params[:network])
    if @network.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to network_path(@project,@network)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @network = Network.find(params[:id])
  end
  
  def update
    @network = Network.find(params[:id])
    if @network.update_attributes(params[:network])
      flash[:notice] = l(:notice_successful_update)
      redirect_to network_path(@project,@network)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @network = Network.find(params[:id])
    @network.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to networks_path(@project)
  end
end
