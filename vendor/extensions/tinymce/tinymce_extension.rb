class TinymceExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://tinymce.com"

  # define_routes do |map|
  #   map.connect 'admin/tinymce/:action', :controller => 'admin/asset'
  # end
  
  def activate
    # admin.tabs.add "Tinymce", "/admin/tinymce", :after => "Layouts", :visibility => [:all]    
    Radiant::PageEditorUI.editors.add(TinymceEditorUI.new)
#    admin.editors.add("Tinymce", TinymceEditorUI)
  end
  
  def deactivate
    Radiant::PageEditorUI.editors.remove(TinymceEditorUI.new)
    # admin.tabs.remove "Tinymce"
  end
    
end