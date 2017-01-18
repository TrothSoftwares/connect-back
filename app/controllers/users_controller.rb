class UsersController < ApplicationController
  # include ErrorSerializer

  before_action :set_user, only: [:show, :update, :destroy]
  wrap_parameters :user, include: [:name, :password, :password_confirmation ,:phone]
  # skip_before_action :authenticate_user_from_token! , only: [:create]
  # skip_before_action :authenticate_user! ,  only: [:create]




  respond_to :json



  def create

    puts params.inspect
    # @user = User.create( :name => params[:name] ,  :password =>  params[:password], :password_confirmation =>  params[:password_confirmation] , :phone  => params[:phone] )
    @user = User.create( user_params)



     if @user.errors.full_messages.empty?
       render json: @user, status: :created, location: @user
      #  data = {
      #    user_id: @user.id,
      #    token: @user.authentication_token,
      #    phone: @user.phone
       #
      #  }
      #  render json: data  ,  status: :created
     else
    render json: @user.errors, status: :unprocessable_entity
     end

  end


  def index
    @user = User.all
    render json: @user, status: :ok
  end


  def show
    render json: @user
  end



  def update
    # logger.info params.inspect
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end


  def user_params
    params.fetch(:user, {}).permit(:name , :password , :password_confirmation , :phone)
  end

end
