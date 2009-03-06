class ContentEditorUI < Radiant::PageEditorUI::DefaultEditor

  def logger
    ActiveRecord::Base.logger;
  end
  
  def name
    "content"
  end
  
  def initialize
    @regions = HashWithIndifferentAccess.new
    @partials = []

    self << 'content_edit_form';
    self.add "edit_title", :region => :form
    self.add "edit_extended_metadata", :region => :form
    self.add "content_editor", :region => :form

#    self.add "edit_page_parts", :region => :form
#    self.add "edit_layout_and_type", :region => :form

    self.add "content_status", :region => :form
    self.add "edit_timestamp", :region => :form
    self.add "content_edit_buttons", :region => :form_bottom
    #self.regions = Array.new;
    self << "popups"
#    self.regions[:form].delete("edit_layout_and_type")
  end    
  
end