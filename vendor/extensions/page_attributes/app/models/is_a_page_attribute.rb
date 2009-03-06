#I bet there's some cool reflection-based way to define these in fewer lines
#But this is clean enough
#This module also serves as an Java-style interface of sorts for classes that include IsAPageAttribute
#maybe I could write a def included method to enforce this more strictly
module IsAPageAttribute
  
  def index
    page_attribute.index
  end
  
  def index=(val)
    page_attribute.index=val
  end
  
  def name
    page_attribute.name  
  end

  def name=(val)
    page_attribute.name=val  
  end
    
  def is_template
    page_attribute.is_template  
  end

  def is_template=(val)
    page_attribute.is_template=val  
  end
  
end