module StandardTags
  
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  desc %{
    Causes the tags referring to a page's attributes to refer to the current page.
   
    *Usage:* 
    <pre><code><r:page>...</r:page></code></pre>
  }
  tag 'page' do |tag|
    tag.locals.page = tag.globals.page
    tag.expand
  end
  
  [:breadcrumb, :slug, :title].each do |method|
    desc %{      
      Renders the @#{method}@ attribute of the current page.
    }    
    tag(method.to_s) do |tag|
      tag.locals.page.send(method)
    end
  end
  
  desc %{      
    Renders the url attribute of the current page.
  }
  tag('url') do |tag|
    tag.locals.page.url_for_link_to
  end

  # desc %{      
  #   Renders the url_for_link_to attribute of the current page.
  # }
  # tag('url_for_link_to') do |tag|
  #   tag.locals.page.url_for_link_to
  # end  

  desc %{  
    Gives access to a page's children.
    
    *Usage:* 
    <pre><code><r:children>...</r:children></code></pre>
  }
  tag 'children' do |tag|
    tag.locals.children = tag.locals.page.children
    tag.expand
  end
  
  desc %{
    Renders the total number of children.
  }
  tag 'children:count' do |tag|
    tag.locals.children.count
  end
  
  desc %{  
    Returns the first child. Inside this tag all page attribute tags are mapped to
    the first child. Takes the same ordering options as @<r:children:each>@.
    
    *Usage:*
    <pre><code><r:children:first>...</r:children:first></code></pre>
  }
  tag 'children:first' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if first = children.first
      tag.locals.page = first
      tag.expand
    end
  end
  
  desc %{
    Returns the last child. Inside this tag all page attribute tags are mapped to
    the last child. Takes the same ordering options as @<r:children:each>@.
    
    *Usage:*
    <pre><code><r:children:last>...</r:children:last></code></pre>
  }
  tag 'children:last' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if last = children.last
      tag.locals.page = last
      tag.expand
    end
  end
  
  desc %{ 
    Cycles through each of the children. Inside this tag all page attribute tags
    are mapped to the current child page.

    *Usage:*
    <pre><code><r:children:each [offset="number"] [limit="number"] [by="attribute"] [order="asc|desc"] 
     [status="draft|reviewed|published|hidden|all"]>
     ...
    </r:children:each>
    </code></pre>
  }
  tag 'children:each' do |tag|
    options = children_find_options(tag)
    result = []
    children = tag.locals.children
    tag.locals.previous_headers = {}
    children.find(:all, options).each do |item|
      tag.locals.child = item
      tag.locals.page = item
      result << tag.expand
    end 
    result
  end
  
  desc %{
    Page attribute tags inside of this tag refer to the current child. Not needed in
    most cases.
    
    *Usage:*
    <pre><code><r:children:each>
      <r:child>...</r:child>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:child' do |tag|
    tag.locals.page = tag.locals.child
    tag.expand
  end

  desc %{  
    Renders the tag contents only if the contents do not match the previous header. This
    is extremely useful for rendering date headers for a list of child pages.
  
    If you would like to use several header blocks you may use the @name@ attribute to
    name the header. When a header is named it will not restart until another header of
    the same name is different.
  
    Using the @restart@ attribute you can cause other named headers to restart when the
    present header changes. Simply specify the names of the other headers in a semicolon
    separated list.
   
    *Usage:*
    <pre><code><r:children:each>
      <r:header [name="header_name"] [restart="name1[;name2;...]"]>
        ...
      </r:header>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:header' do |tag|
    previous_headers = tag.locals.previous_headers
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    header = tag.expand
    unless header == previous_headers[name]
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      header
    end
  end


  desc %{
    Page attribute tags inside this tag refer to the parent of the current page.
    
    *Usage:*
    <pre><code><r:parent>...</r:parent></code></pre>
  }
  tag "parent" do |tag|
    parent = tag.locals.page.parent
    tag.locals.page = parent
    tag.expand if parent
  end
  
  desc %{    
    Renders the contained elements only if the current contextual page has a parent, i.e. 
    is not the root page.
    
    *Usage:*
    <pre><code><r:if_parent>...</r:if_parent></code></pre>
  }
  tag "if_parent" do |tag|
    parent = tag.locals.page.parent
    tag.expand if parent
  end
  
  desc %{    
    Renders the contained elements only if the current contextual page has no parent, i.e. 
    is the root page.
  
    *Usage:*
    <pre><code><r:unless_parent>...</r:unless_parent></code></pre>
  }
  tag "unless_parent" do |tag|
    parent = tag.locals.page.parent
    tag.expand unless parent
  end
  
  desc %{ 
    Renders one of the passed values based on a global cycle counter.  Use the @reset@
    attribute to reset the cycle to the beginning.  Use the @name@ attribute to track 
    multiple cycles; the default is @cycle@.
   
    *Usage:*
    <pre><code><r:cycle values="first, second, third" [reset="true|false"] [name="cycle"] /></code></pre>
  } 
  tag 'cycle' do |tag|
    raise TagError, "`cycle' tag must contain a `values' attribute." unless tag.attr['values']
    cycle = (tag.globals.cycle ||= {})
    values = tag.attr['values'].split(",").collect(&:strip)
    cycle_name = tag.attr['name'] || 'cycle'
    current_index = (cycle[cycle_name] ||=  0)
    current_index = 0 if tag.attr['reset'] == 'true'
    cycle[cycle_name] = (current_index + 1) % values.size
    values[current_index]
  end
  
  desc %{ 
    Renders the main content of a page. Use the @part@ attribute to select a specific
    page part. By default the @part@ attribute is set to body. Use the @inherit@
    attribute to specify that if a page does not have a content part by that name that
    the tag should render the parent's content part. By default @inherit@ is set to
    @false@. Use the @contextual@ attribute to force a part inherited from a parent
    part to be evaluated in the context of the child page. By default 'contextual'
    is set to true.
   
    *Usage:*
    <pre><code><r:content [part="part_name"] [inherit="true|false"] [contextual="true|false"] /></code></pre>
  }
  tag 'content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    boolean_attr = proc do |attribute_name, default|
      attribute = (tag.attr[attribute_name] || default).to_s
      raise TagError.new(%{`#{attribute_name}' attribute of `content' tag must be set to either "true" or "false"}) unless attribute =~ /true|false/i
      (attribute.downcase == 'true') ? true : false
    end
    inherit = boolean_attr['inherit', false]
    part_page = page
    if inherit
      while (part_page.part(part_name).nil? and (not part_page.parent.nil?)) do
        part_page = part_page.parent
      end
    end
    contextual = boolean_attr['contextual', true]
    if inherit and contextual
      part = part_page.part(part_name)
      page.render_snippet(part) unless part.nil?
    else
      part_page.render_part(part_name)
    end
  end
  
  desc %{ 
    Renders the containing elements only if the part exists on a page. By default the
    @part@ attribute is set @body@.
    
    *Usage:*
    <pre><code><r:if_content [part="part_name"]>...</r:if_content></code></pre>
  }
  tag 'if_content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    unless page.part(part_name).nil?
      tag.expand
    end
  end
  
  desc %{
    The opposite of the @if_content@ tag.
   
    *Usage:*
    <pre><code><r:unless_content [part="part_name"]>...</r:unless_content></code></pre>
  }
  tag 'unless_content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    if page.part(part_name).nil?
      tag.expand
    end
  end
  
  desc %{  
    Renders the containing elements only if the page's url matches the regular expression
    given in the @matches@ attribute. If the @ignore_case@ attribute is set to false, the
    match is case sensitive. By default, @ignore_case@ is set to true.
   
    *Usage:*
    <pre><code><r:if_url matches="regexp" [ignore_case="true|false"]>...</if_url></code></pre>
  }
  tag 'if_url' do |tag|
    raise TagError.new("`if_url' tag must contain a `matches' attribute.") unless tag.attr.has_key?('matches')
    regexp = build_regexp_for(tag, 'matches')
    unless tag.locals.page.url.match(regexp).nil?
       tag.expand
    end
  end
  
  desc %{
    The opposite of the @if_url@ tag.
   
    *Usage:*
    <pre><code><r:unless_url matches="regexp" [ignore_case="true|false"]>...</unless_url></code></pre>
  }  
  tag 'unless_url' do |tag|
    raise TagError.new("`unless_url' tag must contain a `matches' attribute.") unless tag.attr.has_key?('matches')
    regexp = build_regexp_for(tag, 'matches')
    if tag.locals.page.url.match(regexp).nil?
        tag.expand
    end
  end
      
  desc %{ 
    Renders the name of the author of the current page.
  }
  tag 'author' do |tag|
    page = tag.locals.page
    if author = page.created_by
      author.name
    end
  end
  
  desc %{ 
    Renders the date that a page was published (or in the event that it has
    not been modified yet, the date that it was created). The format attribute
    uses the same formating codes used by the Ruby @strftime@ function. By
    default it's set to @%A, %B %d, %Y@.
   
    *Usage:*  
    <pre><code><r:date [format="format_string"] /></code></pre>
  }
  tag 'date' do |tag|
    page = tag.locals.page
    format = (tag.attr['format'] || '%A, %B %d, %Y')
    if date = page.published_at || page.created_at
      date.strftime(format)
    end
  end
  
  desc %{ 
    Renders a link to the page. When used as a single tag it uses the page's title
    for the link name. When used as a double tag the part in between both tags will
    be used as the link text. The link tag passes all attributes over to the HTML
    @a@ tag. This is very useful for passing attributes like the @class@ attribute
    or @id@ attribute. If the @anchor@ attribute is passed to the tag it will
    append a pound sign (<code>#</code>) followed by the value of the attribute to
    the @href@ attribute of the HTML @a@ tag--effectively making an HTML anchor.
   
    *Usage:*
    <pre><code><r:link [anchor="name"] [other attributes...] /></code></pre>
    or
    <pre><code><r:link [anchor="name"] [other attributes...]>link text here</r:link></code></pre>
  }
  tag 'link' do |tag|
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    logger.debug("rendering link tag for: #{text}" + tag.render('url').inspect)
    %{<a href="#{tag.render('url')}#{anchor}"#{attributes}>#{text}</a>}
  end

  desc %{
    Renders a trail of breadcrumbs to the current page. The separator attribute
    specifies the HTML fragment that is inserted between each of the breadcrumbs. By
    default it is set to @>@.
    
    *Usage:* 
    <pre><code><r:breadcrumbs [separator="separator_string"] /></code></pre>
  }
  tag 'breadcrumbs' do |tag|
    page = tag.locals.page
    breadcrumbs = [page.breadcrumb]
    page.ancestors.each do |ancestor|
      breadcrumbs.unshift %{<a href="#{ancestor.url}">#{ancestor.breadcrumb}</a>}
    end
    separator = tag.attr['separator'] || ' &gt; '
    breadcrumbs.join(separator)
  end

  desc %{     
    Renders the snippet specified in the @name@ attribute within the context of a page.
    
    *Usage:*
    <pre><code><r:snippet name="snippet_name" /></code></pre>
  }
  tag 'snippet' do |tag|
    if name = tag.attr['name']
      if snippet = Snippet.find_by_name(name.strip)
        page = tag.locals.page
        page.render_snippet(snippet)
      else
        raise TagError.new('snippet not found')
      end
    else
      raise TagError.new("`snippet' tag must contain `name' attribute")
    end
  end
  
  desc %{
    Inside this tag all page related tags refer to the page found at the @url@ attribute.
    
    *Usage:*
    <pre><code><r:find url="value_to_find">...</r:find></code></pre>
  }
  tag 'find' do |tag|
    if url = tag.attr['url']
      if found = Page.find_by_url(tag.attr['url'])
        tag.locals.page = found
        tag.expand
      end
    else
      raise TagError.new("`find' tag must contain `url' attribute")
    end
  end
  
  desc %{       
    Randomly renders one of the options specified by the @option@ tags.
   
    *Usage:*
    <pre><code><r:random>
      <r:option>...</r:option>
      <r:option>...</r:option>
      ...
    <r:random>
    </code></pre>    
  }
  tag 'random' do |tag|
    tag.locals.random = []
    tag.expand
    options = tag.locals.random
    option = options[rand(options.size)]
    option.call if option
  end
  tag 'random:option' do |tag|
    items = tag.locals.random
    items << tag.block
  end
  
  desc %{  
    Nothing inside a set of comment tags is rendered.
    
    *Usage:*
    <pre><code><r:comment>...</r:comment></code></pre>
  }
  tag 'comment' do |tag|
  end
  
  desc %{  
    Escapes angle brackets, etc. for rendering in an HTML document.
    
    *Usage:*
    <pre><code><r:escape_html>...</r:escape_html></code></pre>
  }
  tag "escape_html" do |tag|
    CGI.escapeHTML(tag.expand)
  end
  
  desc %{
    Outputs the published date using the format mandated by RFC 1123. (Ideal for RSS feeds.)
    
    *Usage:*
    <pre><code><r:rfc1123_date /></code></pre>
  }
  tag "rfc1123_date" do |tag|
    page = tag.locals.page
    if date = page.published_at || page.created_at
      CGI.rfc1123_date(date.to_time)
    end
  end
    
  desc %{ 
    Renders a list of links specified in the @urls@ attribute according to three
    states:
    
    * @normal@ specifies the normal state for the link
    * @here@ specifies the state of the link when the url matches the current
       page's URL
    * @selected@ specifies the state of the link when the current page matches
       is a child of the specified url
    
    The @between@ tag specifies what sould be inserted in between each of the links.
    
    *Usage:*
    <pre><code><r:navigation urls="[Title: url; Title: url; ...]"   --OR--
                        childrenOf="parent utl"                     --OR--
                        level="distance from /">
      <r:normal><a href="<r:url />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><strong><a href="<r:url />"><r:title /></a></strong></r:selected>
      <r:between> | </r:between>
    </r:navigation>
    </code></pre>
  }
  tag 'navigation' do |tag|
    hash = tag.locals.navigation = {}
    tag.expand
    raise TagError.new("`navigation' tag must include a `normal' tag") unless hash.has_key? :normal
    result = []
    if(tag.attr['urls'])
      pairs = tag.attr['urls'].to_s.split(';').collect do |pair|
        parts = pair.split(':')
        value = parts.pop
        key = parts.join(':')
        [key.strip, value.strip, value.strip]
      end
    elsif(tag.attr['childrenOf'])
      options = children_find_options(tag)      
      parent = Page.find_by_url(tag.attr['childrenOf']);
      pairs = parent.children.find(:all, options).collect do |page|
        value = page.url
        key = page.title
        [key, value, value]
      end
    elsif(tag.attr['level'])
      options = children_find_options(tag)
      parent = tag.locals.page.parents[tag.attr['level'].to_i - 1]
      if(parent.nil?)        
        return
      end
      logger.debug("showing children of: " + parent.title)
      pairs = parent.children.find(:all, options).collect do |page|
        value = page.url
        key = page.title
        [key, value, page.url_for_link_to]
      end
    end
    pairs.each do |title, url_for_compare, url_to_use|
      compare_url = remove_trailing_slash(url_for_compare)
      page_url = remove_trailing_slash(self.url)
      hash[:title] = title
      hash[:url] = url_to_use
      case page_url
      when compare_url
        result << (hash[:here] || hash[:selected] || hash[:normal]).call
      when Regexp.compile( '^' + Regexp.quote(url_for_compare))
        result << (hash[:selected] || hash[:normal]).call
      else
        result << hash[:normal].call
      end
    end
    between = hash.has_key?(:between) ? hash[:between].call : ' '
    result.join(between)
  end
  [:normal, :here, :selected, :between].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol] = tag.block
    end
  end
  [:title, :url].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol]
    end
  end
  
  private
  
    def children_find_options(tag)
      attr = tag.attr.symbolize_keys
    
      options = {}
      
      [:limit, :offset].each do |symbol|
        if number = attr[symbol]
          if number =~ /^\d{1,4}$/
            options[symbol] = number.to_i
          else
            raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
          end
        end
      end
      
      by = (attr[:by] || 'published_at').strip
      order = (attr[:order] || 'asc').strip
      order_string = ''
      if self.attributes.keys.include?(by)
        order_string << by
      else
        raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
      end
      if order =~ /^(asc|desc)$/i
        order_string << " #{$1.upcase}"
      else
        raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
      end
      options[:order] = order_string
      
      status = (attr[:status] || 'published').downcase
      unless status == 'all'
        stat = Status[status]
        unless stat.nil?
          options[:conditions] = ["(virtual = ?) and (status_id = ?)", false, stat.id]
        else
          raise TagError.new(%{`status' attribute of `each' tag must be set to a valid status})
        end
      else
        options[:conditions] = ["virtual = ?", false]
      end
      options
    end
    
    def remove_trailing_slash(string)
      (string =~ %r{^(.*?)/$}) ? $1 : string
    end
    
    def tag_part_name(tag)
      tag.attr['part'] || 'body'
    end
    
    def build_regexp_for(tag, attribute_name)
      ignore_case = tag.attr.has_key?('ignore_case') && tag.attr['ignore_case']=='false' ? nil : true
      begin
        regexp = Regexp.new(tag.attr['matches'], ignore_case)
      rescue RegexpError => e
        raise TagError.new("Malformed regular expression in `#{attribute_name}' argument of `#{tag.name}' tag: #{e.message}")
      end
      return regexp
    end
  
end