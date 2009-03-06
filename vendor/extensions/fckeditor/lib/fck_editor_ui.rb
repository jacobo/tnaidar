class FCKEditorUI < Radiant::PageEditorUI::DefaultEditor

  def name
    "FCK editor"
  end
  
  def initialize
    super
    
    #Don't display the tabControl of page parts, instead display TinyMCE
    self.regions[:form].delete("edit_page_parts");
    self.add "fck_editor", :region => :form, :before => 'edit_layout_and_type'

    #Need to add an "onsubmit" action to the page edit form
    self.delete('edit_form');
    self << 'fck_edit_form';
  end
  
end