class TinymceEditorUI < Radiant::PageEditorUI::DefaultEditor

  def name
    "tinyMCE"
  end
  
  def initialize
    super
    
    #Don't display the tabControl of page parts, instead display TinyMCE
    self.regions[:form].delete("edit_page_parts");
    self.add "tiny_mce_editor", :region => :form, :before => 'edit_layout_and_type'

    #Need to add an "onsubmit" action to the page edit form
    self.delete('edit_form');
    self << 'mce_edit_form';
  end
  
end