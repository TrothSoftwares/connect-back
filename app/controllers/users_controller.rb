class UsersController < ApplicationController
  # include ErrorSerializer

  before_action :set_user, only: [:show, :update, :destroy]
  wrap_parameters :user, include: [:name, :password, :password_confirmation ,:phone]
  skip_before_action :authenticate_user_from_token! , only: [:create]
  skip_before_action :authenticate_user! ,  only: [:create]


  require 'uri'
  require 'net/http'


  respond_to :json




  def forgotsendotp

    puts params

    @user = User.where("phone = ?", params[:phone] ).first
    if @user

      otpcode = @user.otp_code





      puts "http://2factor.in/API/V1/"+ENV['OTP_SECRET']+"/SMS/"+@user.phone+"/"+otpcode

      url = URI("http://2factor.in/API/V1/"+ENV['OTP_SECRET']+"/SMS/"+@user.phone+"/"+otpcode)

      http = Net::HTTP.new(url.host, url.port)

      request = Net::HTTP::Get.new(url)
      request.body = "{}"

      response = http.request(request)
      render json: {message:'OTP Send'}, status: :ok

    else

      render json: {message:'User does not exist with that phone number'} ,  status: :unprocessable_entity
    end
  end







  def forgotauthenticateotp


    @user = User.where("phone = ?", params[:phone] ).first
    otp = params[:otp]
    if @user
      if @user.authenticate_otp(otp, drift: 60)
        @user.otpconfirmed = true
        @user.save

        loggedinuser = sign_in(:user, @user)

        data = {
          user_id: loggedinuser.id,
          token: loggedinuser.authentication_token,
          phone: loggedinuser.phone,
          otpconfirmed: loggedinuser.otpconfirmed
        }
        logger.info data

        render json: data, status: :ok
      else
        render json: {message:'Incorrect OTP'} ,  status: :unprocessable_entity
      end

    else

      render json: {message:'User does not exist with that phone number'} ,  status: :unprocessable_entity
    end

  end




  def authenticateotp
    @user = User.find(params[:user_id])
    otp = params[:otp]
    if @user.authenticate_otp(otp, drift: 60)
      @user.otpconfirmed = true
      @user.save
      render json: {message:'Authentication Successful. '}, status: :ok
    else
      render json: {message:'Incorrect OTP'} ,  status: :unprocessable_entity
    end
  end



  def sendotp
    puts params[:user_id]

    @user = User.find(params[:user_id])

    otpcode = @user.otp_code

    puts "http://2factor.in/API/V1/"+ENV['OTP_SECRET']+"/SMS/"+@user.phone+"/"+otpcode

    url = URI("http://2factor.in/API/V1/"+ENV['OTP_SECRET']+"/SMS/"+@user.phone+"/"+otpcode)

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request.body = "{}"

     response = http.request(request)
    #response.read_body
    render json: {message:'OTP Send'}, status: :ok
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
