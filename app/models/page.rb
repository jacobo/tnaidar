class Page < ActiveRecord::Base
    
  class MissingRootPageError < StandardError
    def initialize(message = 'Database missing root page'); super end
  end
  
  # Callbacks
  before_save :update_published_at, :update_virtual
  
  # Associations
  acts_as_tree :order => 'virtual DESC, title ASC'
  has_many :parts, :class_name => 'PagePart', :order => 'id', :dependent => :destroy
  belongs_to :_layout, :class_name => 'Layout', :foreign_key => 'layout_id'
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  
  # Validations
  validates_presence_of :title, :slug, :breadcrumb, :status_id, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '%d-character limit'
  validates_length_of :slug, :maximum => 100, :message => '%d-character limit'
  validates_length_of :breadcrumb, :maximum => 160, :message => '%d-character limit'
  
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|/)$}, :message => 'invalid format'
  validates_uniqueness_of :slug, :scope => :parent_id, :message => 'slug already in use for child of parent'
  validates_numericality_of :id, :status_id, :parent_id, :allow_nil => true, :only_integer => true, :message => 'must be a number'
  
  include Radiant::Taggable
  include StandardTags
  include Annotatable
  
  annotate :description
  attr_accessor :request, :response
  
  set_inheritance_column :class_name
      
  def layout
    unless _layout
      parent.layout if parent?
    else
      _layout
    end
  end
  
  def cache?
    true
  end
  
  def child_url(child)
    clean_url(url + '/' + child.slug)
  end
   
  def class_name=(value)
    if (Page.descendants.map(&:to_s) + [nil, "", "Page"]).include?(value) 
      write_attribute(:class_name, value)
    else
      raise ArgumentError.new('class name must be set to a valid descendant of Page')
    end
  end
  
  def headers
    { 'Status' => ActionController::Base::DEFAULT_RENDER_STATUS_CODE }
  end
  
  def part(name)
    parts.find_by_name name.to_s
  end
    
  def published?
    status == Status[:published]
  end
  
  def status
    Status.find(self.status_id)
  end
  def status=(value)
    self.status_id = value.id
  end
  
  def virtual
    !(read_attribute('virtual').to_s =~ /^(false|f|0|)$/)
  end
  
  def url_for_link_to
    result = url
    logger.debug("Base url_for_link_to called on page " + self.title.inspect + " result " + result.inspect)
    return result    
  end
  
  def url
    if parent?
      parent.child_url(self)
    else
      clean_url(slug)
    end
  end
  
  def process(request, response)
    @request, @response = request, response
    if layout
      content_type = layout.content_type.to_s.strip
      @response.headers['Content-Type'] = content_type unless content_type.empty?
    end
    headers.each { |k,v| @response.headers[k] = v }
    @response.body = render
    @request, @response = nil, nil
  end
  
  def render
    lazy_initialize_parser_and_context
    if layout
      parse_object(layout)
    else
      render_part(:body)
    end
  end
  
  def render_part(part_name)
    lazy_initialize_parser_and_context
    
    logger.debug("rendering part: " + part_name.to_s);
    
    part = part(part_name)
    if part
      parse_object(part)
    else
      ''
    end
  end
  
  def render_snippet(snippet)
    lazy_initialize_parser_and_context
    parse_object(snippet)
  end
  
  def render_text(text)
    lazy_initialize_parser_and_context
    parse(text)
  end
  
  def find_by_url(url, live = true, clean = true)
    url = clean_url(url) if clean
    if (self.url == url) && (not live or published?)
      self
    else
      children.each do |child|
        if (url =~ Regexp.compile( '^' + Regexp.quote(child.url))) and (not child.virtual?)
          found = child.find_by_url(url, live, clean)
          return found if found
        end
      end
      children.find(:first, :conditions => "class_name = 'FileNotFoundPage'")
    end
  end
  
  #tells you the depth of this page in relation to the root page
   #root is 0, below that is 1, etc..
   def level
     if parent.nil?
       0
     else
       parent.level + 1;
     end
   end
   
   #gives you a list of parent pages
   #[0] is the root
   def parents
     if parent.nil?
       [self]
     else
       parent.parents + [self]
     end
   end
  
  class << self
    def find_by_url(url, live = true)
      root = find_by_parent_id(nil)
      raise MissingRootPageError unless root
      root.find_by_url(url, live)
    end
    
    def display_name(string = nil)
      if string
        @display_name = string
      else
        @display_name ||= begin
          n = name.to_s
          n.sub!(/^(.+?)Page$/, '\1')
          n.gsub!(/([A-Z])/, ' \1')
          n.strip
        end
      end
    end
    def display_name=(string)
      display_name(string)
    end
    
    def load_subclasses
      Dir["#{RADIANT_ROOT}/app/models/*_page.rb"].each do |page|
        $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
      end
#      Dir["#{RADIANT_ROOT}/vendor/extensions/*/app/models/*_page.rb"].each do |page|
#        load page;
#        $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
#      end
    end
  
  end
  
  private
  
    def attributes_protected_by_default
      super - [self.class.inheritance_column]
    end
  
    def update_published_at
      write_attribute('published_at', Time.now) if (status_id.to_i == Status[:published].id) and published_at.nil?
      true
    end
    
    def update_virtual
      write_attribute('virtual', virtual?)
      true
    end
    
    def clean_url(url)
      "/#{ url.strip }/".gsub(%r{//+}, '/') 
    end
    
    def parent?
      !parent.nil?
    end
    
    def lazy_initialize_parser_and_context
      unless @context and @parser
        @context = PageContext.new(self)
        @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
      end
    end
    
    def parse(text)
      @parser.parse(text)
    end
    
    def parse_object(object)
      text = object.content
      text = parse(text)
      text = object.filter.filter(text) if object.respond_to? :filter_id
      text
    end
    
    def tag(*args, &block)
      @context.define_tag(*args, &block)
    end
  
end


#load "#{RADIANT_ROOT}/vendor/extensions/page_attributes/app/models/template_page.rb"


Page.load_subclasses

#load "#{RADIANT_ROOT}/vendor/extensions/page_attributes/app/models/page.rb"