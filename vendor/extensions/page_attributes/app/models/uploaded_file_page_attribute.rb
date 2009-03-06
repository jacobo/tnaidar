class UploadedFilePageAttribute < ActiveRecord::Base
  
  # Associations
  belongs_to :page_attribute
  acts_as_attachment :storage => :file_system, :size => 1.byte..100.megabytes
  validates_as_attachment

  include IsAPageAttribute

  def self.assign_to_me(page_attribute_val, id_me)
    unless id_me.nil? || id_me.to_s == ""
      uploaded_file = UploadedFilePageAttribute.find(id_me)
      page_attribute_val.uploaded_file_page_attribute = uploaded_file
      uploaded_file.page_attribute = page_attribute_val;
    end
  end
    
  def value
    self.public_filename;
  end

end
