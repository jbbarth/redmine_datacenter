class DatacentersController < DatacenterPluginController
  unloadable

  before_filter :authorize, :find_project, :except => :index
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
    @activity = Redmine::Activity::Fetcher.new(User.current, :project => @project)
    %w(issues wiki_edits changesets).each do |type|
      @activity.scope=([type])
      instance_variable_set("@#{type}", @activity.events(nil, nil, :limit => 3))
      if type == "changesets"
        #patch so that revisions are just displayed with
        #their short identifier in the next section
        @changesets.each do |c|
          def c.event_title
            "#{l(:label_revision)} #{revision.first(8)} #{": "+short_comments unless short_comments.blank?}"
          end
        end
      end
    end
    #nagios integration
    if @datacenter.tool_enabled?(:nagios)
      nagios_file = @datacenter.nagios_file
      begin
        @nagios_status = Nagios::Status.new(nagios_file)
      rescue Errno::ENOENT
        flash.now[:error] = "#{nagios_file}: no such file or directory"
      else
        @nagios_problems = @nagios_status.problems
        @nagios_problems.each do |problem|
          problem[:server] = Server.find_by_name(problem[:host_name])
          problem[:status] = Nagios::Status::STATES[problem[:current_state]]
        end
        @last_updated = Time.at(File.mtime(nagios_file))
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
