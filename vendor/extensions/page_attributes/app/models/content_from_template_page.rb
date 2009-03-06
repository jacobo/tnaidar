# A Content From Template page is a page created in the content area based on a template page
class ContentFromTemplatePage < Page
  validates_presence_of :page_inherit_url, :message => 'required'

  def handle_new(params)
    super(params)
    self.inherit_from_page= self.parent
    self.parent = self.inherit_from_page.parent

    #Add page_attributes for each page_attribute of from_page    
    self.inherit_from_page.page_attributes.each do |page_att| 
      new_page_att = page_att.clone;
      self.page_attributes << new_page_att; 
    end
    
    return self;
  end
    
  def setup_page_parts
    self.inherit_from_page.parts.each do | page_part |
      if page_part.is_template
        new_part = page_part.clone
        new_part.is_template = false
        new_part.page = self
        self.parts << new_part
      end
    end
  end

end