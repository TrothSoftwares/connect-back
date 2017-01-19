class UsersController < ApplicationController
  # include ErrorSerializer

  before_action :set_user, only: [:show, :update, :destroy]
  wrap_parameters :user, include: [:name, :password, :password_confirmation ,:phone]
  # skip_before_action :authenticate_user_from_token! , only: [:create]
  # skip_before_action :authenticate_user! ,  only: [:create]


  require 'uri'
  require 'net/http'


  respond_to :json


def forgotauthenticateotp

  @user = User.where("phone = ?", params[:phone] ).first
  otp = params[:otp]
  # if @user.authenticate_otp(otp, drift: 60)
    @user.otpconfirmed = true
    @user.save

    loggedinuser = sign_in(:user, @user)
    puts loggedinuser.id
data = {
  user_id: loggedinuser.id,
  token: loggedinuser.authentication_token,
  phone: loggedinuser.phone,
  otpconfirmed: loggedinuser.otpconfirmed
}

    render json: data, status: :created

  # else
    # render json: 'incorrect' ,  status: :unprocessable_entity
  # end


end


def forgotsendotp

  puts params[:phone]


   @user = User.where("phone = ?", params[:phone] ).first


  otpcode = @user.otp_code

  puts "http://2factor.in/API/V1/cd592b05-d0d1-11e6-afa5-00163ef91450/SMS/"+@user.phone+"/"+otpcode

  url = URI("http://2factor.in/API/V1/cd592b05-d0d1-11e6-afa5-00163ef91450/SMS/"+@user.phone+"/"+otpcode)

  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Get.new(url)
  request.body = "{}"

  response = http.request(request)
  puts response.read_body

end



  def authenticateotp
    @user = User.find(params[:user_id])
    otp = params[:otp]
    if @user.authenticate_otp(otp, drift: 60)
      @user.otpconfirmed = true
      @user.save
      render json: @user, status: :ok
    else
      render json: 'incorrect' ,  status: :unprocessable_entity
    end
  end



  def sendotp
    puts params[:user_id]

    @user = User.find(params[:user_id])

    otpcode = @user.otp_code

    puts "http://2factor.in/API/V1/cd592b05-d0d1-11e6-afa5-00163ef91450/SMS/"+@user.phone+"/"+otpcode

    url = URI("http://2factor.in/API/V1/cd592b05-d0d1-11e6-afa5-00163ef91450/SMS/"+@user.phone+"/"+otpcode)

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request.body = "{}"

    response = http.request(request)
    puts response.read_body
  end


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
