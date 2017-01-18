class User < ActiveRecord::Base
  before_save :ensure_authentication_token

  devise :database_authenticatable, :recoverable, :trackable, :validatable

  validates_uniqueness_of :phone



  # Generate a token for this user if one does not already exist

  def email_required?
  false
end

def email_changed?
  false
end


  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  # Identical to above except it saves the user
  def ensure_authentication_token!
    ensure_authentication_token
    save
    end

  # Forces a new authentication token to be generated for this user and saves it
  # to the database
  def reset_authentication_token!
    self.authentication_token = generate_authentication_token
    save
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end
end
