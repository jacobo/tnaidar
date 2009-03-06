class ExternalContentExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://external_content.com"

  # define_routes do |map|
  #   map.connect 'admin/external_content/:action', :controller => 'admin/asset'
  # end
  
  def activate
    # admin.tabs.add "External Content", "/admin/external_content", :after => "Layouts", :visibility => [:all]

    Page.send :include, ExternalContentPageExtensions
  end
  
  
  def deactivate
    # admin.tabs.remove "External Content"
  end
    
end