class ApachesController < DatacenterPluginController
  unloadable
  
  before_filter :find_apache_files_and_servers 
  
  helper :repositories
  
  def index
    @virtual_hosts = @servers.map do |server|
      server.virtual_hosts
    end.flatten
  end
  
  def show
    @server = Server.for_datacenter(@datacenter).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def browse
    @server = Server.for_datacenter(@datacenter).find(params[:id])
    if @server.apache_files.include?(params[:file])
      @apache_file = File.read("#{@server.apache_dir}/#{params[:file]}").chomp
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  rescue Errno::ENOENT => e
    flash[:error] = e.message
    redirect_to apaches_path(@project)
  end
  
  protected
  def find_apache_files_and_servers
    apache_dirs = Dir.glob("#{@datacenter.apachedir}/*")
    apache_servers = apache_dirs.map{|f| f.split("/").last}
    @servers = Server.for_datacenter(@datacenter).all(:order => "name").select do |s|
      apache_servers.include?(s.name)
    end
  end
end
