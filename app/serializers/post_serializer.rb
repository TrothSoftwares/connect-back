class PostSerializer < ActiveModel::Serializer
  attributes :id , :title,:body,:createdat


  belongs_to :user

  def createdat
       object.created_at
  end

end
