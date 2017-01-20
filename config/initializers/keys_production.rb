
if Rails.env.production?
  ENV['OTP_SECRET'] = ENV['otp_secret_key']
end
