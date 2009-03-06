class CreatePageAttributesExtensionSchema < ActiveRecord::Migration

  def self.up
    add_column "users", "content_admin", :boolean, :default => false, :null => false

    add_column "page_parts", "is_template", :boolean, :null => false, :default => false

    add_column "pages", "inherit_from_page_id", :integer, :null => true
    add_column "pages", "editable_as_content", :boolean, :null => false, :default => false

    create_table "page_attributes" do |t|
      t.column "name", :string, :limit => 255
      t.column "page_id", :integer, :null => false
      t.column "is_template", :boolean, :null => false, :default => false
      t.column "index", :integer, :null => false
      t.column "class_name", :string, :limit => 255
    end
    
    create_table "string_page_attributes" do |t|
      t.column "page_attribute_id", :integer, :null => false
      t.column "value", :text
    end

    create_table "boolean_page_attributes" do |t|
      t.column "page_attribute_id", :integer, :null => false
      t.column "value", :boolean
    end

    create_table "date_page_attributes" do |t|
      t.column "page_attribute_id", :integer, :null => false
      t.column "value", :date
    end

    create_table "page_link_page_attributes" do |t|
      t.column "page_attribute_id", :integer, :null => false
      t.column "link_to_page_id", :integer  # relationship to another page. (like a spotlight or a link)
      t.column "target_name", :string, :limit => 255 #name to use for target page (if this is an a href)
    end

    create_table "uploaded_file_page_attributes" do |t|
      t.column "page_attribute_id", :integer, :null => false
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      t.column "width", :integer  
      t.column "height", :integer
    end
        
  end


  def self.down
    remove_column "users", "content_admin"
    remove_column "page_parts", "is_template"
    remove_column "pages", "inherit_from_page_id"
    
    remove_column "pages", "editable_as_content"

    drop_table "string_page_attributes"
    drop_table "boolean_page_attributes"
    drop_table "date_page_attributes"
    drop_table "page_link_page_attributes"
    drop_table "uploaded_file_page_attributes"

    drop_table "page_attributes"
  end


end