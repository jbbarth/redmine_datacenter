class ApplisController < DatacenterPluginController
  helper :servers

  def index
    sort_init 'name', 'asc'
    sort_update %w(id name)

    @status = params[:status] ? params[:status].to_i : Server::STATUS_ACTIVE
    c = ARCondition.new(@status == 0 ? nil : ["status = ?", @status])
    
    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      c << ["LOWER(name) LIKE ?", name]
    end

    @appli_count = Appli.count(:conditions => c.conditions)
    @appli_pages = Paginator.new self, @appli_count, per_page_option, params['page']
    @applis =  Appli.all :order => sort_clause,
            :conditions => c.conditions,
            :limit  =>  @appli_pages.items_per_page,
            :offset =>  @appli_pages.current.offset

    render :layout => !request.xhr?
  end
  
  def show
    @appli = Appli.find(params[:id], :include => [:issues, :instances])
    c = ARCondition.new(["#{IssueElement.table_name}.appli_id = ?", @appli.id])
    sort_init([['id', 'desc']])
    sort_update({'id' => "#{Issue.table_name}.id"})
    @issue_count = Issue.count(:joins => :issue_elements, :conditions => c.conditions)
    @issue_pages = Paginator.new self, @issue_count, per_page_option, params['page']
    @issues = Issue.all :order => 'id desc',
                        :joins => :issue_elements,
                        :conditions => c.conditions,
                        :limit => @issue_pages.items_per_page,
                        :offset => @issue_pages.current.offset,
                        :group => 'id',
                        :order => sort_clause
    render :layout => !request.xhr?
  end
  
  def new
    @appli = Appli.new
  end
  
  def create
    @appli = Appli.new(params[:appli])
    if @appli.save
      flash[:notice] = l(:notice_successful_create)
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
      flash[:notice] = l(:notice_successful_update)
      redirect_to @appli
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @appli = Appli.find(params[:id])
    @appli.status = Appli::STATUS_LOCKED
    @appli.save
    redirect_to applis_url
  end
end
