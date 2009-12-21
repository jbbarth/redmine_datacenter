class InstancesController < DatacenterPluginController
  before_filter :find_appli
  
  def index
    sort_init 'name', 'asc'
    sort_update %w(id name)

    @instance_count = Instance.count
    @instance_pages = Paginator.new self, @instance_count, per_page_option, params['page']
    @instances =  Instance.all :order => sort_clause,
            :limit  =>  @instance_pages.items_per_page,
            :offset =>  @instance_pages.current.offset

    render :layout => !request.xhr?
  end
  
  def show
    @instance = Instance.find(params[:id], :include => :issues)
    c = ARCondition.new(["instances_issues.instance_id = ?", @instance.id])
    sort_init([['id', 'desc']])
    sort_update({'id' => "#{Issue.table_name}.id"})
    @issue_count = Issue.count(:joins => :instances, :conditions => c.conditions)
    @issue_pages = Paginator.new self, @issue_count, per_page_option, params['page']
    @issues = Issue.all :order => 'id desc',
                        :joins => :instances,
                        :conditions => c.conditions,
                        :limit => @issue_pages.items_per_page,
                        :offset => @issue_pages.current.offset,
                        :order => sort_clause
    render :layout => !request.xhr?
  end
  
  def new
    @instance = Instance.new
    @servers = Server.active
  end
  
  def create
    @instance = Instance.new(params[:instance])
    @servers = Server.active
    if @instance.save
      flash[:notice] = "Successfully created instance."
      redirect_to @appli
    else
      render :action => 'new'
    end
  end
  
  def edit
    @instance = Instance.find(params[:id])
    @servers = (Server.active + @instance.servers).uniq.sort_by(&:name)
  end
  
  def update
    @instance = Instance.find(params[:id])
    @servers = (Server.active + @instance.servers).uniq.sort_by(&:name)
    if @instance.update_attributes(params[:instance])
      flash[:notice] = "Successfully updated instance."
      redirect_to @appli
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @instance = Instance.find(params[:id])
    @instance.destroy
    flash[:notice] = "Successfully destroyed instance."
    redirect_to @appli
  end

  private
  def find_appli
    @appli = Appli.find(params[:appli_id])
  end
end
