class FckeditorExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://fckeditor.com"

   define_routes do |map|
     map.connect 'admin/fckeditor/:action', :controller => 'fckeditor'
     map.connect 'admin/fckstyles', :controller => 'fckeditor', :action => 'fckstyles'
#     map.connect 'admin/fckeditor/*', :controller => 'admin/fckeditor', :action => 'connector'
   end
  
    def activate
      Radiant::PageEditorUI.editors.add(FCKEditorUI.new)
    end

    def deactivate
      Radiant::PageEditorUI.editors.remove(FCKEditorUI.new)
    end
    
end
