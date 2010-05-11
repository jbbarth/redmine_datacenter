class NestedListsController < ApplicationController
  unloadable
  
  layout 'admin'
  
  before_filter :require_admin
  before_filter :get_klass, :except => :index
  
  def index
  end
  
  def new
    @element = @klass.new
  end
  
  def create
    @element = @klass.new(params[:element])
    if @element.save
      @element.set_parent!(params[:element][:parent_id])
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @element = @klass.find(params[:id])
  end
  
  def update
    @element = @klass.find(params[:id])
    if @element.update_attributes(params[:element])
      @element.set_parent!(params[:element][:parent_id])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @element = @klass.find(params[:id])
    flash[:notice] = l(:notice_successful_delete) if @element.destroy
    redirect_to :action => 'index'
  end
  
  def rebuild
    @klass.update_all({:lft=>nil,:rgt=>nil})
    @klass.rebuild!
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'index'
  end
  
  protected
  def get_klass
    klasses = %w(OperatingSystem)
    type = params[:type]
    begin
      @klass = params[:type].constantize
    rescue NameError
    end
    if @klass.nil? || !klasses.include?(@klass.name)
      flash[:error] = "Stop kidding me, there's no '#{type}' model!"
      redirect_to :action => 'index'
    end
  end
end
