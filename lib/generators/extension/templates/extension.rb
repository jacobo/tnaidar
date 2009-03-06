class <%= class_name %> < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://<%= file_name %>.com"

  # define_routes do |map|
  #   map.connect 'admin/<%= file_name %>/:action', :controller => 'admin/asset'
  # end
  
  def activate
    # admin.tabs.add "<%= extension_name %>", "/admin/<%= file_name %>", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "<%= extension_name %>"
  end
    
end