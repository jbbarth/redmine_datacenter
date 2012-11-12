class ApplisController < DatacenterPluginController
  before_filter :find_appli, :only => [:show, :edit, :update, :destroy]
  unloadable
  helper :servers

  def index
    sort_init 'name', 'asc'
    sort_update %w(id name)

    @status = params[:status] ? params[:status].to_i : Server::STATUS_ACTIVE
    apps = Appli.where(:datacenter_id => @datacenter.id)
    apps = apps.where(:status => @status) unless @status == 0
    
    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      apps = apps.where("LOWER(name) LIKE ?", name)
    end

    @appli_count = apps.count
    @appli_pages = Paginator.new self, @appli_count, per_page_option, params['page']
    @applis =  apps.limit(@appli_pages.items_per_page)
                   .offset(@appli_pages.current.offset)
                   .order(sort_clause)
                   .all

    render :layout => !request.xhr?
  end
  
  def show
    table = IssueElement.table_name
    issues = Issue.where("#{table}.appli_id = ?", @appli.id)
                  .joins(:issue_elements)
    
    case params[:filter].to_s
    when "Appli"
      issues = issues.where("#{table}.element_type = ?", "Appli")
    when /^Instance:(\d+)$/
      issues = issues.where("#{table}.element_type = ? and #{table}.element_id = ?", "Instance", $1)
    end

    sort_init([['id', 'desc']])
    sort_update({'id' => "#{Issue.table_name}.id"})
    @issue_count = issues.count
    @issue_pages = Paginator.new self, @issue_count, per_page_option, params['page']
    @issues = issues.limit(@issue_pages.items_per_page)
                    .offset(@issue_pages.current.offset)
                    .group('id')
                    .order(sort_clause)
    render :layout => !request.xhr?
  end
  
  def new
    @appli = Appli.new
  end
  
  def create
    @appli = Appli.new(params[:appli])
    if @appli.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to appli_path(@project,@appli)
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @appli.update_attributes(params[:appli])
      flash[:notice] = l(:notice_successful_update)
      redirect_to appli_path(@project,@appli)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @appli.status = Appli::STATUS_LOCKED
    @appli.save
    redirect_to applis_url(:project_id => @project)
  end

  private
  def find_appli
    begin
      @appli = Appli.includes([:issues, :instances])
                    .where(:datacenter_id => @datacenter)
                    .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
