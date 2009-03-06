#class Admin::PageController < ApplicationController
module PageControllerExtensions

  def self.included(base)
    base.class_eval do
      
      alias_method :old_handle_new_or_edit_post, :handle_new_or_edit_post
      
      private
      
          def handle_new_or_edit_post(redirect_to_content_view = false)
            if redirect_to_content_view
              flash[:page_editor_ui] = "content"
            end
            
            if request.post?
              @page.attributes = params[:page]

              #original_names = @page.parts.map { |part| part.name }
              #new_names = (params[:part] || {}).values.map { |part| part[:name] }
              #names_to_remove = (original_names - new_names)

              parts_to_update = []
              (params[:part] || {}).values.each do |v|
                if part = @page.parts.find_by_name(v[:name])
                  part.attributes = part.attributes.merge(v)
                  parts_to_update << part
                else
                  parts_to_update << @page.parts.build(v)
                end
              end              
              parts_to_delete = @page.parts.reject{ |part| parts_to_update.include?(part) }
              parts_to_delete.each{ |part| @page.parts.delete(part) }

              atts_to_update = []
              (params[:attribute] || {}).values.each do |v|
                if att = @page.page_attributes.find_by_name(v[:name])
                  att.attributes = att.attributes.merge(v)
                  atts_to_update << att

                  logger.debug("just inited (existing) att: " + att.attributes.to_s);
                else
                  new_page_attribute = PageAttribute.new_from_values(v)
                  @page.page_attributes << new_page_attribute
                  atts_to_update << new_page_attribute

                  logger.debug("just inited att: " + new_page_attribute.attributes.to_s);
                end
              end
              atts_to_delete = @page.page_attributes.reject{ |att| atts_to_update.include?(att) }
              atts_to_delete.each{ |att| @page.page_attributes.delete(att) }

              @page.editable_as_content = false;
              parts_to_update.each do |part| 
                @page.editable_as_content ||= part.is_template 
              end
              @page.editable_as_content = true if atts_to_update.size > 0

              if @page.save
                #names_to_remove.each { |name| @page.parts.find_by_name(name).destroy }
                
                parts_to_update.each { |part| part.save }
                atts_to_update.each { |att| att.save }
                announce_page_saved
                if params[:continue]
                  redirect_to page_edit_url(:id => @page.id)
                else
                  if redirect_to_content_view
                    redirect_to url_for(:controller => 'admin/content')
                  else
                    redirect_to page_index_url
                  end
                end
                return false
              else
                announce_validation_errors
              end
            end
            true
          end

    end
  end

  def edit_content
    @page = Page.find(params[:id])
    render :action => :edit if handle_new_or_edit_post(true)
  end
  
  def new_page_from_template
    @page = Page.new
    @page.slug = params[:slug]
    @page.breadcrumb = params[:breadcrumb]
    @page.parent = Page.find_by_id(params[:parent_id])    

    if @page.parent.template?
      raise "Error: can't create page from template as child of a template"
    end

    @page.inherit_from_page = Page.find_by_id(params[:inherit_from_page])
    @page.layout_id = @page.inherit_from_page.layout_id;
    
    logger.debug("Creating page with layout_id" + @page.layout_id.to_s)
    logger.debug("Creating page from layout_id" + @page.inherit_from_page.layout_id.to_s)
    
    @page.status = @page.inherit_from_page.status
    @page.class_name = "ContentFromTemplatePage"
    if request.get?
      @page.inherit_from_page.parts.each do |part|
        if part.is_template
          new_part = PagePart.new(:name => part.name)
          new_part.is_template = true;
          @page.parts << new_part
        end
      end
      @page.inherit_from_page.page_attributes.each do |page_att| 
        new_page_att = page_att.clone;
        @page.page_attributes << new_page_att; 
      end
    end
    render :action => :edit if handle_new_or_edit_post(true)
  end
    
  # controller
  def inherit_from_page_auto_complete
    value = params[:page][:page_inherit_url];
    @pages = Page.find(:all, 
          :conditions => [ 'LOWER(title) LIKE ?',
          '%' + value.downcase + '%' ], 
          :order => 'title ASC',
          :limit => 8)
    render :partial => 'auto_completed_page'
  end

  def auto_complete_for_page
    value = params[:attribute].values[0][:page_url];
    @pages = Page.find(:all, 
          :conditions => [ 'LOWER(title) LIKE ?',
          '%' + value.downcase + '%' ], 
          :order => 'title ASC',
          :limit => 8)
    render :partial => 'auto_completed_page'
  end
    
  def upload
      logger.debug("params" + params.to_s)
      @uploaded_file = UploadedFilePageAttribute.create! params[:file]
      render(:partial => 'file_upload', :object => @uploaded_file, :layout => false)
  end  

  def add_attribute
    att = PageAttribute.new(params[:attribute])
    att.index = nil;
    render(:partial => 'att', :object => att, :layout => false)
  end

  def delete_upload_attribute
    att = PageAttribute.find(params[:id])
    att.uploaded_file_page_attribute.destroy;
    att.uploaded_file_page_attribute = nil;
    att.save;
  end

end
