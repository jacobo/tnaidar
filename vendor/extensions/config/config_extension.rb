class ConfigExtension < Radiant::Extension
  version "1.0"
  description "Access this extension at /admin/config"
  url "http://config.com"
  
  define_routes do |map|
     map.connect 'admin/config/:action', :controller => 'admin/config'
  end
  
  def activate
    #admin.tabs.add "Config", "/admin/config", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
     #admin.tabs.remove "Config"
  end
  
end