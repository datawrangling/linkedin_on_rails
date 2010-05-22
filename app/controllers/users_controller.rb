class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def show_tooltip
    @user = User.find(params[:user_id])
    @connection = @user.connections.find_by_id(params[:id])
  end

  def create
    @user = User.new(params[:user])
    @user.save do |result|
      if result
        flash[:notice] = "Account registered!"
        redirect_to account_url
      else
        unless @user.oauth_token.nil?
          @user = User.find_by_oauth_token(@user.oauth_token)
          unless @user.nil?
            UserSession.create(@user)
            flash.now[:message] = "Welcome back!"
            redirect_to account_url        
          else
            redirect_back_or_default root_path
          end
        else
          redirect_back_or_default root_path
        end
      end
    end
  end

  def show
    @user = @current_user
    @connections = @user.connections.paginate :page => params[:page], :per_page => 21, :order => 'member_id'
    
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "connection_results" block...works for this example
          # 'page.replace_html' will replace "connection_results" inner html...useful elsewhere
          page.replace 'connection_results', :partial => 'connections'
        end
      }
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
