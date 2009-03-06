class PageLinkPageAttribute < ActiveRecord::Base
  
  belongs_to :page_attribute
  belongs_to :link_to_page, :class_name  => 'Page', :foreign_key => 'link_to_page_id'

  include IsAPageAttribute

  def page_url
    if @page_url.nil?
      if link_to_page.nil?
        return nil
      end
      @page_url = link_to_page.url;
    end
    @page_url
  end

  def page_url=(val)
    @page_url = val
    if( val.nil? || val.to_s == "" )
      self.link_to_page = nil;
    else
      self.link_to_page = Page.find_by_url(self.page_url.to_s, false)
    end
  end
    
end