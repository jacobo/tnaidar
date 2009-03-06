#class Page < ActiveRecord::Base
module PageExtensions
  
  def self.included(base)
    base.class_eval do
      belongs_to :inherit_from_page, :class_name => 'Page', :foreign_key => 'inherit_from_page_id'
      has_many :page_attributes, :class_name => 'PageAttribute', :dependent => :destroy
      
      # This is the mechanism by which everything finds parts
      # we look in super first to see if self has the part asked for
      # And then we check with the inherit_from_page Page and ask it for the part
      # super def is:
      # parts.find_by_name name.to_s
    	alias_method :old_part, :part	
      def part(name)

        logger.debug("finding part: " + name.to_s);

        to_return = parts.find_by_name name.to_s
        if to_return == nil
          if self.inherit_from_page == nil
            to_return = nil
          else
            to_return = self.inherit_from_page.part(name)
          end
        end
        return to_return
      end
            
    end
  end

  def page_inherit_url
    if @page_inherit_url.nil?
      if inherit_from_page.nil?
        return nil
      end
      @page_inherit_url = inherit_from_page.url;
    end
    @page_inherit_url
  end

  def page_inherit_url=(val)
    @page_inherit_url = val
    if( val.nil? || val.to_s == "" )
      self.inherit_from_page = nil;
    else
      self.inherit_from_page = Page.find_by_parent_id(nil).page_for_url(self.page_inherit_url.to_s); 
      #don't allow me to inherit from myself
      if self.inherit_from_page.nil? or self.inherit_from_page.id == self.id
        self.inherit_from_page = nil
      end
    end
  end

  # So this isn't as ideally "DRY" as it could be
  # It might be better for the core page find_by_url to allow an optional param
  # to also find virtual pages
  # but radiant core controls that method, so It's safer to define my own
  def page_for_url(url)
    logger.debug("checking if this page url " + self.url.to_s + " == " + url.to_s);
    if (self.url == url)
      logger.debug("true, match found");
      return self
    else
      children.each do |child|
        if (url =~ Regexp.compile( '^' + Regexp.quote(child.url)))
          found = child.page_for_url(url)
          return found if found
        end
      end
    end
    return nil;
  end
  
  def template?
    class_name == "TemplatePage"
  end

  def content_from_template?
    class_name == "ContentFromTemplatePage"
  end
  
  def title_to_autocomplete
    return self.title;
  end
  
  def admin_editable_attributes
    page_attributes.to_ary.sort{|x,y| x.index <=> y.index }
  end
    
  def setup_page_parts
    ApplicationController.default_parts.each do |name|
        self.parts << PagePart.new(:name => name)
    end
  end

  def attribute(name)
    page_attributes.find_by_name name.to_s
  end
    
end