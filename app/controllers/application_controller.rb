class ApplicationController < ActionController::Base
 before_filter :authenticate_user_from_token!
 before_filter :authenticate_user!

respond_to :json


  private

    def authenticate_user_from_token!
      authenticate_with_http_token do |token, options|
        user_phone = options[:phone].presence
        user = user_phone && User.find_by_phone(user_phone)

        if user && Devise.secure_compare(user.authentication_token, token)
          sign_in user, store: false
        end
      end
    end
end
