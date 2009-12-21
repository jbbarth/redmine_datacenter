class ApplisController < DatacenterPluginController
  helper :servers

  def index
    sort_init 'name', 'asc'
    sort_update %w(id name)

    @appli_count = Appli.count
    @appli_pages = Paginator.new self, @appli_count, per_page_option, params['page']
    @applis =  Appli.all :order => sort_clause,
            :limit  =>  @appli_pages.items_per_page,
            :offset =>  @appli_pages.current.offset

    render :layout => !request.xhr?
  end
  
  def show
    @appli = Appli.find(params[:id], :include => [:issues, :instances])
    c = ARCondition.new(["applis_issues.appli_id = ?", @appli.id])
    sort_init([['id', 'desc']])
    sort_update({'id' => "#{Issue.table_name}.id"})
    @issue_count = Issue.count(:joins => :applis, :conditions => c.conditions)
    @issue_pages = Paginator.new self, @issue_count, per_page_option, params['page']
    @issues = Issue.all :order => 'id desc',
                        :joins => :applis,
                        :conditions => c.conditions,
                        :limit => @issue_pages.items_per_page,
                        :offset => @issue_pages.current.offset,
                        :order => sort_clause
    render :layout => !request.xhr?
  end
  
  def new
    @appli = Appli.new
  end
  
  def create
    @appli = Appli.new(params[:appli])
    if @appli.save
      flash[:notice] = "Successfully created appli."
      redirect_to @appli
    else
      render :action => 'new'
    end
  end
  
  def edit
    @appli = Appli.find(params[:id])
  end
  
  def update
    @appli = Appli.find(params[:id])
    if @appli.update_attributes(params[:appli])
      flash[:notice] = "Successfully updated appli."
      redirect_to @appli
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @appli = Appli.find(params[:id])
    @appli.destroy
    flash[:notice] = "Successfully destroyed appli."
    redirect_to applis_url
  end
end
