# Setup notes...
#
# rake db:migrate:extensions
#
# >> user = User.new
# >> user.attributes = {'name' => 'admin', 'admin' => true, 'password' => 'admin', 'login' => 'admin', 'password_confirmation' => 'admin'}
# >> user.save
#


class PageAttributesExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://page_attributes.com"

  define_routes do |map|
    map.connect 'admin/content/:action/:id', :controller => 'admin/content'
    map.connect  'admin/ui/content/children/:id/:level', :action => 'children', :level => '1', :controller => 'admin/content'
        
    # Page Routes
    map.with_options(:controller => 'admin/page') do |page|
      page.file_upload     'admin/pages/upload',                  :action => 'upload'
      page.page_add_attribute 'admin/ui/pages/part/add_attribute',  :action => 'add_attribute'
      page.new_page_from_template 'admin/pages/new_from_template/:parent_id/:inherit_from_page', :action => 'new_page_from_template'
      page.edit_content 'admin/pages/edit_content/:id', :action => 'edit_content'
      page.any_action 'admin/pages/do/:action/:id'
    end
  end
  
  def activate

    admin.tabs.add "Content", "/admin/content", :before => "Pages", :visibility => [:all]

    Radiant::PageEditorUI.editors.default.add "admin/page/attributes", :region => :form, :after => "edit_page_parts"
    Radiant::PageEditorUI.editors.default.add "admin/page/popups", :region => :popups    
    Radiant::PageEditorUI.editors.add(ContentEditorUI.new)

    Page.send :include, PageTags
    Page.send :include, PageExtensions
    
    Radiant::ExtensionLoader::do_after_activate_extensions do
      Admin::PageController.send :include, PageControllerExtensions

      TemplatePage
      ExternalPage
      ContentFromTemplatePage
    end

  end
  
  def deactivate
    # TODO
    #    admin.tabs.remove "Page Attributes"
  end
    
end
