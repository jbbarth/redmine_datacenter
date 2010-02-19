class NetworksController < DatacenterPluginController
  before_filter :find_network, :only => [:show, :edit, :update, :destroy]
  unloadable

  def index
    @networks = @datacenter.networks
  end
  
  def overview
    @servers = @datacenter.servers.active.all(:order => 'name asc')
    @networks = @datacenter.networks.all(:order => 'address asc')
    
    @display = (%w(by_ip_host side_by_side).include?(params[:display]) ? params[:display] : 'by_subnet')
    
    case @display
    when 'by_subnet'
      @by_network = {}
      @networks.each do |network|
        @by_network[network.name] = []
      end
      @by_network["-"] = [] #for servers outside our networks
    
      #TODO: clean all this, it's just an awful mess
      #      of nested arrays and hashes for the moment :( !
      @servers.each do |server|
        server.interfaces.each do |interface|
          net = @networks.detect{|n| n.include?(interface.ipaddress)}
          key = (net ? net.name : "-")
          @by_network[key] << [server,interface.ipaddress]
        end
      end
    
    when 'by_ip_host'
      @by_ip = {}
      @servers.each do |server|
        server.interfaces.each do |interface|
          @by_ip[interface.ipaddress] = server
        end
      end

    when 'side_by_side'
      @side = {}
      @servers.each do |server|
        @side[server.id] = Hash.new("")
        server.interfaces.each do |interface|
          net = @networks.detect{|n| n.include?(interface.ipaddress)}
          key = (net ? net.id : "-")
          @side[server.id][key] = interface.ipaddress
        end
      end
      
    end
  end

  def show
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
  end
  
  def update
    if @network.update_attributes(params[:network])
      flash[:notice] = l(:notice_successful_update)
      redirect_to network_path(@project,@network)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @network.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to networks_path(@project)
  end

  private
  def find_network
    begin
      @network = Network.find(params[:id],
                          :conditions => {:datacenter_id => @datacenter})
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
