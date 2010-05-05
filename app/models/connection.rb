class Connection < ActiveRecord::Base
  belongs_to :user
  
  def picture
    if self.picture_url != nil
      url = self.picture_url
    else  
      url= "icon_no_photo_80x80.png"
    end  
  end
      
end
