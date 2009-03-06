require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  fixtures :users, :pages, :page_parts, :snippets, :layouts
  test_helper :pages, :page_parts, :validations, :render

  def setup
    @page_title = 'Page Title'
    destroy_test_page
    
    @part_name = 'test-part'
    destroy_test_part
    
    @page = @model = Page.new(VALID_PAGE_PARAMS)
    
    @request = ActionController::TestRequest.new :url => '/page/'
    @response = ActionController::TestResponse.new
  end
  
  def test_mixins
    assert Page.included_modules.include?(StandardTags)
  end
  
  def test_validates_length_of
    {
      :title => 255,
      :slug => 100,
      :breadcrumb => 160
    }.each do |field, max|
      assert_invalid field, ('%d-character limit' % max), 'x' * (max + 1)
      assert_valid field, 'x' * max
    end
  end
  
  def test_validates_presence_of
    [:title, :slug, :breadcrumb].each do |field|
      assert_invalid field, 'required', '', ' ', nil
    end 
  end
  
  def test_validates_format_of
    @page.parent = pages(:homepage)
    assert_valid :slug, 'abc', 'abcd-efg', 'abcd_efg', 'abc.html', '/', '123'
    assert_invalid :slug, 'invalid format', 'abcd efg', ' abcd', 'abcd/efg'
  end
  
  def test_validates_numericality_of
    assert_invalid :status_id, 'required', '', nil
    [:id, :status_id, :parent_id].each do |field|
      assert_valid field, '1', '2'
      assert_invalid field, 'must be a number', 'abcd', '1,2', '1.3'
    end
  end

  def test_validates_uniqueness_of
    @page.parent = pages(:radius)
    assert_invalid :slug, 'slug already in use for child of parent', 'child-1', 'child-2', 'child-3'
    assert_valid :slug, 'child-4'
  end

  def test_included_modules
    assert Page.included_modules.include?(Annotatable), 'Annotatable is not included'
  end

  def test_layout
    @page = pages(:page_with_layout)
    assert_equal 1, @page.layout_id
    assert_kind_of Layout, @page.layout
  end

  def test_parts
    @homepage = pages(:homepage)
    assert_equal(4, @homepage.parts.count)
    
    @documentation = pages(:documentation)
    assert_equal(1, @documentation.parts.count)
  end
  
  def test_destroy__parts_dependant
    @page = create_test_page
    @page.parts.create(part_params(:name => @part_name, :page_id => nil))
    assert_kind_of PagePart, @page.parts.find_by_name(@part_name)
    
    id = @page.id
    @page.destroy
    assert_nil PagePart.find_by_page_id_and_name(id, @part_name)
  end

  def test_part
    part = pages(:radius).part('body')
    assert_equal 'body', part.name
  end
  def test_part__lookup_by_symbol
    part = pages(:radius).part(:body)
    assert_equal 'body', part.name
  end

  def test_published_at
    @page = create_test_page(:status_id => '1')
    assert_nil @page.published_at
    
    @page.status_id = Status[:published].id
    @page.save
    assert_not_nil @page.published_at
    assert_equal Time.now.day, @page.published_at.day
  end  
  def test_published_at__not_updated_on_save_because_already_published
    @page = create_test_page(:status_id => Status[:published].id)
    assert_kind_of Time, @page.published_at
    
    expected = @page.published_at
    @page.save
    assert_equal expected, @page.published_at
  end
  
  def test_published
    @page.status = Status[:published]
    assert_equal true, @page.published?
  end
  def test_published__not_published
    @page.status = Status[:draft]
    assert_equal false, @page.published?
  end

  def test_url
    @page = pages(:parent)
    assert_equal '/parent/', @page.url
    assert_equal '/parent/child/', @page.children.first.url
    
    grandchild = pages(:grandchild)
    assert_equal '/parent/child/grandchild/', grandchild.url
  end
  
  def test_child_url
    @page = pages(:parent)
    child = pages(:child)
    assert_equal '/parent/child/', @page.child_url(child)
  end
  
  def test_find_by_url_1
    @page = pages(:homepage)
    assert_equal @page, @page.find_by_url('/') 
  end
  def test_find_by_url_2
    @page = pages(:homepage)
    expected = pages(:great_grandchild)
    found = @page.find_by_url('/parent/child/grandchild/great-grandchild/')
    assert_equal expected, found 
  end
  def test_find_by_url_3
    @page = pages(:homepage)
    assert_equal pages(:article), @page.find_by_url('/archive/2000/05/01/article/')
  end
  def test_find_by_url__when_virtual
    @page = pages(:homepage)
    found = @page.find_by_url('/archive/2006/02/05/month/')
    assert_equal nil, found
  end
  def test_find_by_url__when_not_found_and_missing_page_defined
    @page = pages(:homepage)
    found = @page.find_by_url('/gallery/asdf/')
    assert_instance_of FileNotFoundPage, found
  end
  def test_find_by_url__when_not_found_on_live
    @page = pages(:homepage)
    found = @page.find_by_url('/gallery/gallery_draft/')
    assert_instance_of FileNotFoundPage, found
  end
  def test_find_by_url__when_not_found_on_dev
    @page = pages(:homepage)
    expected = pages(:gallery_draft)
    found = @page.find_by_url('/gallery/gallery_draft/', false)
    assert_equal expected, found
  end  

  def test_find_by_url_class_method
    @root = pages(:homepage)
    assert_equal @root, Page.find_by_url('/')
    
    @page = pages(:books)
    assert_equal @page, Page.find_by_url('/documentation/books/')
    
    @root = pages(:homepage)
    assert_equal 'File Not Found', Page.find_by_url('/gallery/gallery_draft/').title
    assert_equal 'Gallery Draft', Page.find_by_url('/gallery/gallery_draft/', false).title
  end
  def test_find_by_url_class_method__raises_exception_when_root_missing
    pages(:homepage).destroy
    assert_nil Page.find_by_parent_id(nil)
    e = assert_raises(Page::MissingRootPageError) { Page.find_by_url "/" }
    assert_equal 'Database missing root page', e.message
  end
  
  def test_headers
    expected = { 'Status' => ActionController::Base::DEFAULT_RENDER_STATUS_CODE }
    assert_equal expected, @page.headers
  end
  
  def test_render
    expected = 'This is the body portion of the Ruby home page.'
    assert_page_renders :homepage, expected
  end
  def test_render__with_filter
    expected = '<p>Some <strong>Textile</strong> content.</p>'
    assert_page_renders :textile, expected
  end
  def test_render__with_tags
    expected = "<h1>Radius Test Page</h1>\n\n\n\t<ul>\n\t<li>Radius Test Child 1</li>\n\t\t<li>Radius Test Child 2</li>\n\t\t<li>Radius Test Child 3</li>\n\t</ul>"
    assert_page_renders :radius, expected
  end
  def test_render__with_layout
    expected = "<html>\n  <head>\n    <title>Page With Layout</title>\n  </head>\n  <body>\n    Page With Layout\n  </body>\n</html>\n"
    assert_page_renders :page_with_layout, expected
  end
  
  def test_render_snippet
    assert_snippet_renders :first, 'test'
  end
  def test_render_snippet_with_filter
    assert_snippet_renders :markdown, '<p><strong>markdown</strong></p>'
  end
  def test_render_snippet_with_tag
    assert_snippet_renders :snippet_with_tag, 'New Page'
  end
  
  def test_process
    @page = pages(:textile)
    @page.process(@request, @response)
    assert_match %r{Some <strong>Textile</strong> content.}, @response.body
  end
  def test_process_with_headers
    @page = pages(:test_page)
    @page.process(@request, @response)
    assert_equal 'beans', @response.headers['cool']
    assert_equal 'TestRequest', @response.headers['request']
    assert_equal 'TestResponse', @response.headers['response']
  end
  def test_process__page_with_content_type_set_on_layot
    @page = pages(:page_with_content_type_set_on_layout)
    @page.process(@request, @response)
    assert_response :success
    assert_equal 'text/html;charset=utf8', @response.headers['Content-Type']
  end

  def test_status
    @page = pages(:homepage)
    assert_equal Status[:published], @page.status
  end
  
  def test_set_status
    @page = pages(:homepage)
    draft = Status[:draft]
    @page.status = draft
    assert_equal draft, @page.status
    assert_equal draft.id, @page.status_id
  end
  
  def test_cache
    assert_equal true, @page.cache?
  end
  
  def test_layout__inherited
    @page = pages(:child_of_page_with_layout)
    assert_equal nil, @page.layout_id
    assert_equal @page.parent.layout, @page.layout
  end
  
  def test_virtual?
    assert_equal false, @page.virtual?
  end
   
  def test_before_save
    @page = create_test_page(:class_name => "ArchiveMonthIndexPage")
    assert_kind_of ArchiveMonthIndexPage, @page
    assert_equal true, @page.virtual?
    assert_equal true, @page.virtual
  end
  
  def test_annotations
    assert_equal 'this is just a test page', TestPage.description
  end
  
  def test_defined_tags
    assert_page_renders :test_page, 'Hello world! Another test.'
  end
  def test_defined_tags_are_unique_for_each_behavior
    assert_render_error %r{undefined tag `test1'}, '<r:test1 />'
  end
  
  def test_render_part
    @page = pages(:test_page)
    assert_equal "Hello world! Another test.", @page.render_part(:body)
  end

  def test_render_text
    @page = pages(:homepage)
    assert_equal "/", @page.render_text( "<r:slug />")
  end
  
  def test_display_name_class_method
    assert_equal "Page", Page.display_name
    
    assert_equal "Test", TestPage.display_name
    
    TestPage.display_name = "New Name"
    assert_equal "New Name", TestPage.display_name
    
    assert_equal "File Not Found", FileNotFoundPage.display_name
  end
  
  def test_decendants_class_method
    descendants = Page.descendants
    assert_kind_of Array, descendants
    assert_match /TestPage/, descendants.inspect
  end

  def test_mass_assignment_for_class_name
    @page = Page.new
    @page.attributes = { :class_name => 'ArchivePage' }
    assert_equal 'ArchivePage', @page.class_name
  end
  
  def test_mass_assignment_class_name_must_be_set_to_a_valid_descendant
    @page = Page.new
    e = assert_raises(ArgumentError) do
      @page.attributes = { :class_name => 'Object' }
    end
  end
  
  def test_class_name_must_be_a_valid_descendant
    @page = Page.new
    e = assert_raises(ArgumentError) { @page.class_name = 'Object' }
    assert_equal nil, @page.class_name
    assert_equal 'class name must be set to a valid descendant of Page', e.message
  end
  
  def test_class_name_can_be_set_to_page_or_empty_or_nil
    [nil, '', 'Page'].each do |value|
      @page = ArchivePage.new
      assert_nothing_raised { @page.class_name = value }
      assert_equal value, @page.class_name
    end
  end

end
