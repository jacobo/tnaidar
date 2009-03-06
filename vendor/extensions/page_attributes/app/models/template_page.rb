# A Template page should not ever be displayed on the front-end
# 
# Content area can be used to create ContentFromTemplatePage based on TemplatePage
# 
class TemplatePage < Page
  
  description %{
    pages like this are templates?
  }
  
  def render
    throw "Error: can't render a template"
  end

  def virtual?
    true
  end
  
end