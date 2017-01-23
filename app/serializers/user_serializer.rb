class UserSerializer < ActiveModel::Serializer
  attributes :id , :name , :phone ,:otpconfirmed



  has_many :posts






end
