class DatePageAttribute < ActiveRecord::Base
  
  belongs_to :page_attribute

  include IsAPageAttribute
  
end