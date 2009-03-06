class PageAttribute < ActiveRecord::Base
  
  belongs_to :page

  has_one :boolean_page_attribute, :class_name => 'BooleanPageAttribute', :dependent => :destroy
  has_one :string_page_attribute, :class_name => 'StringPageAttribute', :dependent => :destroy
  has_one :page_link_page_attribute, :class_name => 'PageLinkPageAttribute', :dependent => :destroy
  has_one :uploaded_file_page_attribute, :class_name => 'UploadedFilePageAttribute', :dependent => :destroy
  has_one :date_page_attribute, :class_name => 'DatePageAttribute', :dependent => :destroy
  
  def save
    super
    self.att_value.save;
  end
  
  #follow normal method_missing and if still not found, 
  #look for the method on associated attribute object (att_value)
  def method_missing(method_name, *args)
    begin
      super;
    rescue NoMethodError => e
        self.att_value.send(method_name, *args);
    end
  end

  #return the value for the one :has_one relationship this object has (or should have) a value for
  #(as determined by self.class_name)
  #all other has_one relations should lead to nil
  def att_value
    relation = PageAttribute.class_name_to_relation[self.class_name.to_s]
    if self.send(relation.name).nil?
      self.send(relation.name.to_s+"=", PageAttribute.class_eval(relation.class_name).new)
    end
    return self.send(relation.name)
  end
  
  #a hash for finding out information about this objects's has_one relationships
  #lookup is based on the name of the relation
  def self.class_name_to_relation
    hash = Hash.new
    PageAttribute.reflect_on_all_associations(:has_one).each do
      |relation|
      hash[relation.class_name] = relation
    end
    return hash
  end
      
  #We need this map of [class_name => class_name,..] 
  #for creating the select a page attribute drop-down
  def self.implementing_classes_mapped
    hash = Hash.new
    PageAttribute.reflect_on_all_associations(:has_one).each do
      |relation|
      hash[relation.class_name] = relation.class_name
    end
    return hash
  end
  
  #to be called implcitly by form submit if needed (via attributes=)
  #to delegate the setup of a particular attribute type to the implementing class
  def id_to_me=(val)
    PageAttribute.class_eval(class_name).assign_to_me(self, val)
  end
  
  #Need to make sure that self.class_name is initialized first
  #Otherwise, we could just use attributes= 
  def self.new_from_values(init_params)
    #if we are using id_to_me (for file uploads) then
    if init_params[:id_to_me]
      return self.new(init_params)
    else
      new_page_att = self.new;
      new_page_att.class_name = init_params[:class_name];
      new_page_att.attributes = init_params;
      return new_page_att
    end
  end  
  
end