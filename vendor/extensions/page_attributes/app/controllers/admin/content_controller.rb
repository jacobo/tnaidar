class Admin::ContentController < ApplicationController
  
  def index
    @homepage = Page.find_by_parent_id(nil)    
  end  
  
  def new_page
    @page = Page.new
    @page.slug = params[:slug]
    @page.breadcrumb = params[:breadcrumb]
    @page.parent = Page.find_by_id(params[:parent_id])
    @page.class_name = "ContentFromTemplatePage"
    if request.get?
      default_parts.each do |name|
        @page.parts << PagePart.new(:name => name)
      end
    end
#    render :action => :edit if handle_new_or_edit_post
  end
  
  def children
    @parent = Page.find(params[:id])   
#    if @parent.content_from_template?
#      @parent = @parent.inherit_from_page
#    end
    @level = params[:level].to_i
    response.headers['Content-Type'] = 'text/html;charset=utf-8'
    render :layout => false
  end
  
end