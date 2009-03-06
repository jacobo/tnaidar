module Admin::PageHelper
  def render_node(page, locals = {})
    locals.reverse_merge!(:level => 0, :simple => false, :simulated_parent => false).merge!(:page => page)
    render :partial => 'node', :locals =>  locals
  end

  def expanded_rows
    rows = case
    when row_string = (cookies['expanded_rows'] || []).first
      row_string.split(',').map { |x| Integer(x) rescue nil }.compact
    else
      []
    end
    (rows << homepage.id).uniq
  end
  
  def meta_errors?
    !!(@page.errors[:slug] or @page.errors[:breadcrumb])
  end
  
  def tag_reference(class_name)
    returning String.new do |output|
      class_name.constantize.tag_descriptions.sort.each do |tag_name, description|
        output << render(:partial => "tag_reference", 
            :locals => {:tag_name => tag_name, :description => description})
      end
    end
  end
  
  def filter_reference(filter_name)
    unless filter_name.blank?
      filter_class = (filter_name + "Filter").constantize
      filter_class.description.blank? ? "There is no documentation on this filter." : filter_class.description
    else
      "There is no filter on the current page part."
    end
  end
  
  def default_filter_name
    @page.parts.empty? ? "" : @page.parts[0].filter_id
  end
  
  def homepage
    @homepage ||= Page.find_by_parent_id(nil)
  end
  
  def render_region(name)
    returning String.new do |output|
      unless editor_ui.regions[name].blank?
        editor_ui.regions[name].compact.each do |partial|
          output << render(:partial => partial)
        end
      end
    end
  end
  
  def render_page_edit_partials
    returning String.new do |output|
      editor_ui.render_edit_partials(self, output) 
    end
  end
  
  def editor_ui
    if(flash[:page_editor_ui])
      to_return = Radiant::PageEditorUI.editors[flash[:page_editor_ui]]
    end
    unless to_return and to_return != nil
      to_return = Radiant::PageEditorUI.editors[session[:page_editor_ui]]
    end
    if to_return.nil?
      Radiant::PageEditorUI.editors.default
    else
      to_return
    end
  end
    
  def additional_page_scripts(&block)
    @page_scripts ||= String.new
    @page_scripts << capture(&block)
  end

  def additional_page_styles(&block)
    @page_styles ||= String.new
    @page_styles << capture(&block)
  end
  
  def render_page_scripts
    returning render_region(:scripts) do |output|
      unless @page_scripts.blank?
        output << @page_scripts
      end
    end
  end
  
  def render_page_styles
    returning render_region(:styles) do |output|
      unless @page_styles.blank?
        output << @page_styles
      end
    end
  end
end
