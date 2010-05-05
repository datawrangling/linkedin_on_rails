class PositionsController < ApplicationController
  def index
     @user = User.find(params[:user_id])
     @positions = @user.comments 
  end

  def show
     @user = User.find(params[:user_id])  
     @position = @user.positions.find(params[:id]) 
  end

  def new
    @user = User.find(params[:user_id])
    @position = @user.positions.build     
  end

  def create
    @user = User.find(params[:user_id])
    @position = @user.positions.build(params[:position])
    if @position.save
      redirect_to user_position_url(@user, @position)
    else
      render :action => "new" 
    end
  end  
         
  def edit
  end

end


