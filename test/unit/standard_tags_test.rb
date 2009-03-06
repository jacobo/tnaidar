require File.dirname(__FILE__) + '/../test_helper'

class StandardTagsTest < Test::Unit::TestCase
  
  fixtures :pages, :page_parts, :layouts, :snippets, :users
  test_helper :render, :pages
  
  def setup
    @page = pages(:radius)
  end
  
  def test_tag_page
    assert_renders 'Radius Test Page', '<r:title />'
    assert_renders 'Ruby Home Page | Radius Test Page', %{<r:find url="/"><r:title /> | <r:page:title /></r:find>}
  end
  
  def test_tags_page_attributes
    [:breadcrumb, :slug, :title, :url].each do |attr|
      value = @page.send(attr)
      assert_renders value.to_s, "<r:#{attr} />"
    end
  end
  
  def test_tag_children
    expected = 'Radius Test Child 1 Radius Test Child 2 Radius Test Child 3 '
    input = '<r:children:each><r:title /> </r:children:each>'
    assert_renders expected, input
  end
  def test_tag_children_each
    assert_renders 'radius/child-1 radius/child-2 radius/child-3 ' , '<r:children:each><r:page><r:slug />/<r:child:slug /> </r:page></r:children:each>'
  end
  def test_tag_children_each_attributes
    @page = pages(:assorted)
    assert_renders 'a b c d e f g h i j ', page_children_each_tags
    assert_renders 'a b c d e ',           page_children_each_tags(%{limit="5"})
    assert_renders 'd e f g h ',           page_children_each_tags(%{offset="3" limit="5"})
    assert_renders 'j i h g f e d c b a ', page_children_each_tags(%{order="desc"})
    assert_renders 'f e d c b a j i h g ', page_children_each_tags(%{by="breadcrumb"})
    assert_renders 'g h i j a b c d e f ', page_children_each_tags(%{by="breadcrumb" order="desc"})
  end
  def test_tag_children_each_with_status_attribute
    @page = pages(:assorted)
    assert_render_match /^(draft |)a b c d e f g h i j( draft|) $/, page_children_each_tags(%{status="all"})
    assert_renders 'draft ', page_children_each_tags(%{status="draft"})
    assert_renders 'a b c d e f g h i j ', page_children_each_tags(%{status="published"})
    assert_render_error "`status' attribute of `each' tag must be set to a valid status", page_children_each_tags(%{status="askdf"})
  end
  def test_tag_children_each_attributes_with_invalid_limit
    message = "`limit' attribute of `each' tag must be a positive number between 1 and 4 digits"
    assert_render_error message, page_children_each_tags(%{limit="a"})
    assert_render_error message, page_children_each_tags(%{limit="-10"})
    assert_render_error message, page_children_each_tags(%{limit="50000"})
  end
  def test_tag_children_each_attributes_with_invalid_offset
    message = "`offset' attribute of `each' tag must be a positive number between 1 and 4 digits"
    assert_render_error message, page_children_each_tags(%{offset="a"})
    assert_render_error message, page_children_each_tags(%{offset="-10"})
    assert_render_error message, page_children_each_tags(%{offset="50000"})
  end
  def test_tag_children_each_attributes_with_invalid_by_field_name
    message = "`by' attribute of `each' tag must be set to a valid field name"
    assert_render_error message, page_children_each_tags(%{by="non-existant-field"})
  end
  def test_tag_children_each_attributes_with_invalid_limit
    message = %{`order' attribute of `each' tag must be set to either "asc" or "desc"}
    assert_render_error message, page_children_each_tags(%{order="asdf"})
  end
  def test_tag_children_each_does_not_list_virtual_pages
    @page = pages(:archive)
    assert_renders 'article article-2 article-3 article-4 article-5 ', '<r:children:each><r:slug /> </r:children:each>'
    assert_render_match /^(draft |)article article-2 article-3 article-4 article-5( draft|) $/, '<r:children:each status="all"><r:slug /> </r:children:each>'
  end
  
  def test_tag_children_each_header
    @page = pages(:archive)
    assert_renders '[May/00] article [Jun/00] article-2 article-3 [Aug/00] article-4 [Aug/01] article-5 ', '<r:children:each><r:header>[<r:date format="%b/%y" />] </r:header><r:slug /> </r:children:each>'
  end
  def test_tag_children_each_header_with_name_attribute
    @page = pages(:archive)
    assert_renders '[2000] (May) article (Jun) article-2 article-3 (Aug) article-4 [2001] article-5 ', %{<r:children:each><r:header name="year">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:children:each>}  
  end
  def test_tag_children_each_header_with_restart_attribute
    @page = pages(:archive)
    assert_renders(
      '[2000] (May) article (Jun) article-2 article-3 (Aug) article-4 [2001] (Aug) article-5 ',
      %{<r:children:each><r:header name="year" restart="month">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:children:each>}
    )
    assert_renders(
      '[2000] (May) <01> article (Jun) <09> article-2 <10> article-3 (Aug) <06> article-4 [2001] (Aug) <06> article-5 ',
      %{<r:children:each><r:header name="year" restart="month;day">[<r:date format='%Y' />] </r:header><r:header name="month" restart="day">(<r:date format="%b" />) </r:header><r:header name="day"><<r:date format='%d' />> </r:header><r:slug /> </r:children:each>}
    )
  end
  
  def test_tag_children_count
    assert_renders '3', '<r:children:count />'
  end
  
  def test_tag_children_first
    assert_renders 'Radius Test Child 1', '<r:children:first:title />'
  end
  def test_tag_children_first_parameters
    @page = pages(:assorted)
    assert_renders 'a', page_children_first_tags
    assert_renders 'a', page_children_first_tags(%{limit="5"})
    assert_renders 'd', page_children_first_tags(%{offset="3" limit="5"})
    assert_renders 'j', page_children_first_tags(%{order="desc"})
    assert_renders 'f', page_children_first_tags(%{by="breadcrumb"})
    assert_renders 'g', page_children_first_tags(%{by="breadcrumb" order="desc"})
  end
  def test_tag_children_first_is_nil
    @page = pages(:textile)
    assert_renders '', '<r:children:first:title />'
  end
  
  def test_tag_children_last
    assert_renders 'Radius Test Child 3', '<r:children:last:title />'
  end
  def test_tag_children_last_parameters
    @page = pages(:assorted)
    assert_renders 'j', page_children_last_tags
    assert_renders 'e', page_children_last_tags(%{limit="5"})
    assert_renders 'h', page_children_last_tags(%{offset="3" limit="5"})
    assert_renders 'a', page_children_last_tags(%{order="desc"})
    assert_renders 'g', page_children_last_tags(%{by="breadcrumb"})
    assert_renders 'f', page_children_last_tags(%{by="breadcrumb" order="desc"})
  end
  def test_tag_children_last_nil
    @page = pages(:textile)
    assert_renders '', '<r:children:last:title />'
  end
  
  def test_tag_content
    expected = "<h1>Radius Test Page</h1>\n\n\n\t<ul>\n\t<li>Radius Test Child 1</li>\n\t\t<li>Radius Test Child 2</li>\n\t\t<li>Radius Test Child 3</li>\n\t</ul>"
    assert_renders expected, '<r:content />'
  end
  def test_tag_content_with_part_attribute
    assert_renders "Just a test.\n", '<r:content part="extended" />'
  end
  def test_tag_content_with_inherit_attribute
    assert_renders '', '<r:content part="sidebar" />'
    assert_renders '', '<r:content part="sidebar" inherit="false" />'
    assert_renders 'Radius Test Page sidebar.', '<r:content part="sidebar" inherit="true" />'
    assert_render_error %{`inherit' attribute of `content' tag must be set to either "true" or "false"}, '<r:content part="sidebar" inherit="weird value" />'

    assert_renders '', '<r:content part="part_that_doesnt_exist" inherit="true" />'
  end
  def test_tag_content_with_inherit_and_contextual_attributes
    assert_renders 'Radius Test Page sidebar.', '<r:content part="sidebar" inherit="true" contextual="true" />'
    assert_renders 'Ruby Home Page sidebar.', '<r:content part="sidebar" inherit="true" contextual="false" />'
    
    @page = pages(:inheritance_test_page_grandchild)
    assert_renders 'Inheritance Test Page Grandchild inherited body.', '<r:content part="body" inherit="true" contextual="true" />'
  end
  
  def test_tag_child_content
    expected = "Radius test child 1 body.\nRadius test child 2 body.\nRadius test child 3 body.\n"
    assert_renders expected, '<r:children:each><r:content /></r:children:each>'
  end
  
  def test_tag_if_content_without_body_attribute
    assert_renders 'true', '<r:if_content>true</r:if_content>'
  end
  def test_tag_if_content_with_body_attribute
    assert_renders 'true', '<r:if_content part="body">true</r:if_content>'
  end
  def test_tag_if_content_with_nonexistant_body_attribute
    assert_renders '', '<r:if_content part="asdf">true</r:if_content>'
  end
  
  def test_tag_unless_content_without_body_attribute
    assert_renders '', '<r:unless_content>false</r:unless_content>'
  end
  def test_tag_unless_content_with_body_attribute
    assert_renders '', '<r:unless_content part="body">false</r:unless_content>'
  end
  def test_tag_unless_content_with_nonexistant_body_attribute
    assert_renders 'false', '<r:unless_content part="asdf">false</r:unless_content>'
  end
  
  def test_tag_author
    assert_renders 'Admin User', '<r:author />'
  end
  def test_tag_author_nil
    @page = pages(:textile)
    assert_renders '', '<r:author />'
  end
  
  def test_tag_date
    assert_renders 'Monday, January 30, 2006', '<r:date />'
  end
  def test_tag_date_with_format_attribute
    assert_renders '30 Jan 2006', '<r:date format="%d %b %Y" />'
  end
  
  def test_tag_link
    assert_renders '<a href="/radius/">Radius Test Page</a>', '<r:link />'
  end
  def test_tag_link__attributes
    expected = '<a href="/radius/" class="test" id="radius">Radius Test Page</a>'
    assert_renders expected, '<r:link class="test" id="radius" />'
  end
  def test_tag_link__block_form
    assert_renders '<a href="/radius/">Test</a>', '<r:link>Test</r:link>'
  end
  def test_tag_link__anchor
    assert_renders '<a href="/radius/#test">Test</a>', '<r:link anchor="test">Test</r:link>'
  end
  def test_tag_child_link
    expected = "<a href=\"/radius/child-1/\">Radius Test Child 1</a> <a href=\"/radius/child-2/\">Radius Test Child 2</a> <a href=\"/radius/child-3/\">Radius Test Child 3</a> "
    assert_renders expected, '<r:children:each><r:link /> </r:children:each>' 
  end
  
  def test_tag_snippet
    assert_renders 'test', '<r:snippet name="first" />'
  end
  def test_tag_snippet_not_found
    assert_render_error 'snippet not found', '<r:snippet name="non-existant" />'
  end
  def test_tag_snippet_without_name
    assert_render_error "`snippet' tag must contain `name' attribute", '<r:snippet />'
  end
  def test_tag_snippet_with_markdown
    assert_renders '<p><strong>markdown</strong></p>', '<r:page><r:snippet name="markdown" /></r:page>'
  end

  def test_tag_random
    assert_render_match /^(1|2|3)$/, "<r:random> <r:option>1</r:option> <r:option>2</r:option> <r:option>3</r:option> </r:random>"
  end
  
  def test_tag_comment
    assert_renders 'just a test', 'just a <r:comment>small </r:comment>test'
  end
  
  def test_tag_navigation_1
    tags = %{<r:navigation urls="Home: Boy: /; Archives: /archive/; Radius: /radius/; Docs: /documentation/">
               <r:normal><a href="<r:url />"><r:title /></a></r:normal>
               <r:here><strong><r:title /></strong></r:here>
               <r:selected><strong><a href="<r:url />"><r:title /></a></strong></r:selected>
               <r:between> | </r:between>
             </r:navigation>}
    expected = %{<strong><a href="/">Home: Boy</a></strong> | <a href="/archive/">Archives</a> | <strong>Radius</strong> | <a href="/documentation/">Docs</a>}
    assert_renders expected, tags
  end
  def test_tag_navigation_2
    tags = %{<r:navigation urls="Home: /; Archives: /archive/; Radius: /radius/; Docs: /documentation/">
               <r:normal><r:title /></r:normal>
             </r:navigation>}
    expected = %{Home Archives Radius Docs}
    assert_renders expected, tags
  end
  def test_tag_navigation_3
    tags = %{<r:navigation urls="Home: /; Archives: /archive/; Radius: /radius/; Docs: /documentation/">
               <r:normal><r:title /></r:normal>
               <r:selected><strong><r:title/></strong></r:selected>
             </r:navigation>}
    expected = %{<strong>Home</strong> Archives <strong>Radius</strong> Docs}
    assert_renders expected, tags
  end
  def test_tag_navigation_without_urls
    assert_renders '', %{<r:navigation></r:navigation>}
  end
  def test_tag_navigation_without_urls
    assert_render_error  "`navigation' tag must include a `normal' tag", %{<r:navigation urls="something:here"></r:navigation>}
  end
  def test_tag_navigation_with_urls_without_slashes
    tags = %{<r:navigation urls="Home: ; Archives: /archive; Radius: /radius; Docs: /documentation">
               <r:normal><r:title /></r:normal>
               <r:here><strong><r:title /></strong></r:here>
             </r:navigation>}
    expected = %{Home Archives <strong>Radius</strong> Docs}
    assert_renders expected, tags
  end
  
  def test_tag_find
    assert_renders 'Ruby Home Page', %{<r:find url="/"><r:title /></r:find>}
  end
  def test_tag_find_without_url
    assert_render_error "`find' tag must contain `url' attribute", %{<r:find />}
  end
  def test_tag_find_with_nonexistant_url
    assert_renders '', %{<r:find url="/asdfsdf/"><r:title /></r:find>}
  end
  
  def test_tag_find_and_children
    assert_renders 'a-great-day-for-ruby another-great-day-for-ruby ', %{<r:find url="/news/"><r:children:each><r:slug /> </r:children:each></r:find>}
  end
  
  def test_tag_escape_html
    assert_renders '&lt;strong&gt;a bold move&lt;/strong&gt;', '<r:escape_html><strong>a bold move</strong></r:escape_html>'
  end
  
  def test_tag_rfc1123_date
    @page.published_at = Time.utc(2004, 5, 2)
    assert_renders 'Sun, 02 May 2004 00:00:00 GMT', '<r:rfc1123_date />'
  end
  
  def test_tag_breadcrumbs
    @page = pages(:deep_nested_child_for_breadcrumbs)
    assert_renders '<a href="/">Home</a> &gt; <a href="/radius/">Radius Test Page</a> &gt; <a href="/radius/child-1/">Radius Test Child 1</a> &gt; Deeply nested child',
      '<r:breadcrumbs />'
  end
  def test_tag_breadcrumbs_with_separator_attribute
    @page = pages(:deep_nested_child_for_breadcrumbs)
    assert_renders '<a href="/">Home</a> :: <a href="/radius/">Radius Test Page</a> :: <a href="/radius/child-1/">Radius Test Child 1</a> :: Deeply nested child',
      '<r:breadcrumbs separator=" :: " />'
  end
  
  def test_tag_if_url_does_not_match
    assert_renders '', '<r:if_url matches="fancypants">true</r:if_url>'
  end
  def test_tag_if_url_matches
     assert_renders 'true', '<r:if_url matches="r.dius/$">true</r:if_url>'
  end
  def test_tag_if_url_without_ignore_case
    assert_renders 'true', '<r:if_url matches="rAdius/$">true</r:if_url>'
  end
  def test_tag_if_url_with_ignore_case_true
    assert_renders 'true', '<r:if_url matches="rAdius/$" ignore_case="true">true</r:if_url>'
  end
  def test_tag_if_url_with_ignore_case_false
    assert_renders '', '<r:if_url matches="rAdius/$" ignore_case="false">true</r:if_url>'
  end
  def test_tag_if_url_with_malformatted_regexp
    assert_render_error "Malformed regular expression in `matches' argument of `if_url' tag: unmatched (: /r(dius\\/$/", '<r:if_url matches="r(dius/$">true</r:if_url>'
  end
  def test_tag_if_url_empty
    assert_render_error "`if_url' tag must contain a `matches' attribute.", '<r:if_url>test</r:if_url>'
  end
  
  def test_tag_unless_url_does_not_match
    assert_renders 'true', '<r:unless_url matches="fancypants">true</r:unless_url>'
  end
  def test_tag_unless_url_matches
    assert_renders '', '<r:unless_url matches="r.dius/$">true</r:unless_url>'
  end
  def test_tag_unless_url_without_ignore_case
    assert_renders '', '<r:unless_url matches="rAdius/$">true</r:unless_url>'
  end
  def test_tag_unless_url_with_ignore_case_true
    assert_renders '', '<r:unless_url matches="rAdius/$" ignore_case="true">true</r:unless_url>'
  end
  def test_tag_unless_url_with_ignore_case_false
    assert_renders 'true', '<r:unless_url matches="rAdius/$" ignore_case="false">true</r:unless_url>'
  end
  def test_tag_unless_url_with_malformatted_regexp
    assert_render_error "Malformed regular expression in `matches' argument of `unless_url' tag: unmatched (: /r(dius\\/$/", '<r:unless_url matches="r(dius/$">true</r:unless_url>'
  end
  def test_tag_unless_url_empty
    assert_render_error "`unless_url' tag must contain a `matches' attribute.", '<r:unless_url>test</r:unless_url>'
  end
  
  def test_tag_cycle
    assert_renders 'first second', '<r:cycle values="first, second" /> <r:cycle values="first, second" />'
  end
  def test_tag_cycle_returns_to_beginning
    assert_renders 'first second first', '<r:cycle values="first, second" /> <r:cycle values="first, second" /> <r:cycle values="first, second" />'
  end
  def test_tag_cycle_default_name
    assert_renders 'first second', '<r:cycle values="first, second" /> <r:cycle values="first, second" name="cycle" />'
  end
  def test_tag_cycle_keeps_separate_counters
    assert_renders 'first one second two', '<r:cycle values="first, second" /> <r:cycle values="one, two" name="numbers" /> <r:cycle values="first, second" /> <r:cycle values="one, two" name="numbers" />'
  end
  def test_tag_cycle_resets_counter
    assert_renders 'first first', '<r:cycle values="first, second" /> <r:cycle values="first, second" reset="true"/>'    
  end
  def test_tag_cycle_names_empty
    assert_render_error "`cycle' tag must contain a `values' attribute.", '<r:cycle />'
  end
  
  def test_tag_parent
    assert_renders pages(:homepage).title, '<r:parent><r:title /></r:parent>'
    assert_renders page_eachable_children(pages(:homepage)).collect(&:title).join(""), '<r:parent><r:children:each by="title"><r:title /></r:children:each></r:parent>'
    assert_renders @page.title * @page.children.count, '<r:children:each><r:parent:title /></r:children:each>'
  end
  def test_tag_if_parent
    assert_renders 'true', '<r:if_parent>true</r:if_parent>'
    @page = pages(:homepage)
    assert_renders '', '<r:if_parent>true</r:if_parent>'
  end
  def test_tag_unless_parent
    assert_renders '', '<r:unless_parent>true</r:unless_parent>'
    @page = pages(:homepage)
    assert_renders 'true', '<r:unless_parent>true</r:unless_parent>'
  end
  
  private
  
    def page_children_first_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:children:first#{attr}><r:slug /></r:children:first>"
    end
    
    def page_children_last_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:children:last#{attr}><r:slug /></r:children:last>"
    end
    
    
    def page_children_each_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:children:each#{attr}><r:slug /> </r:children:each>"
    end
  
    def page_eachable_children(page)
      page.children.select(&:published?).reject(&:virtual)
    end
end