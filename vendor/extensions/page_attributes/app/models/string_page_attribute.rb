class StringPageAttribute < ActiveRecord::Base
  
  # Associations
  belongs_to :page_attribute

  include IsAPageAttribute

end