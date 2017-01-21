class SessionsController < Devise::SessionsController
  respond_to :json

  skip_before_action :authenticate_user_from_token! , only: [:create]
  skip_before_action :authenticate_user! ,  only: [:create]

   # POST /api/users/sign_in
   def create
     respond_to do |format|
       format.json do
         self.resource = warden.authenticate!(auth_options)
         data = {
           user_id: resource.id,
           token: resource.authentication_token,
           phone: resource.phone,
           otpconfirmed: resource.otpconfirmed
           
         }
         render json: data, status: :created

       end
     end
   end
end
