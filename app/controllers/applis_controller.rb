class ApplisController < DatacenterController
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
    @appli = Appli.find(params[:id])
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
