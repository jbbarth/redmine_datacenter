class CrontabsController < DatacenterPluginController
  unloadable
  
  before_filter :find_cron_files_and_servers 
  
  def index
  end
  
  def show
    begin
      @server = Server.find(params[:id],
                            :conditions => {:datacenter_id=>@datacenter})
    rescue ActiveRecord::RecordNotFound
      render_404
    end
    if @server
      begin
        @cron_lines = File.readlines(@server.crontab_file).map{|l| l.chomp}
      rescue Errno::ENOENT => e
        flash[:error] = e.message
      end
      @cron_lines = ["mi h d m w user command"] if @cron_lines.nil? || @cron_lines.empty?
      @cron_lines[0] = "mi h d m w user command" if @cron_lines[0] == "mithtdtmtwtusertcommand"
    end
  end
  
  protected
  def find_cron_files_and_servers
    cron_files = Dir.glob("#{@datacenter.crondir}/*")
    cron_servers = cron_files.map{|f| f.split("/").last}
    @servers = Server.for_datacenter(@datacenter).all(:order => "name").select do |s|
      cron_servers.include?(s.name)
    end
  end
end
