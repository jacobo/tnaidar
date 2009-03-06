class PagePreviewExtension < Radiant::Extension
  version "0.1"
  description "A sample page-preview functionality.  An example of how you can hook into the page-editing interface with the enhancements in the 'facets' branch."
  url "http://radiantcms.org"

  define_routes do |map|
    map.preview_page "admin/page/preview/:id", :controller => "admin/page", :action => "preview"
  end
  
  def activate
    require 'application'

    # To Load just for the default editor do this instead:
    # Radiant::PageEditorUI.editors.default.add "preview/preview_button", :region => :buttons    

    Radiant::ExtensionLoader::do_after_activate_extensions do
      Radiant::PageEditorUI.each_editor{ |editor| editor.add "preview/preview_button", :region => :buttons }
    end
    
    Admin::PageController.send :include, PreviewControllerExtensions
  end
  
  def deactivate
    Radiant::PageEditorUI.each_editor{ |editor| editor.regions[:buttons].delete("preview/preview_button") }
  end

end