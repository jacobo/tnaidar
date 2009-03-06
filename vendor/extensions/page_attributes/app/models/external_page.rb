# A Template page should not ever be displayed on the front-end
# 
# Content area can be used to create ContentFromTemplatePage based on TemplatePage
# 
class ExternalPage < Page
  
  description %{
    pages like this are supposed to be used as the layout for an external page
  }
  
  def url_for_link_to
    # logger.debug("url_for_link_to  called!!1" + self.inspect)
    if att = self.attribute("External URL")
      return att.value
    else
      return super
    end
  end
  
end