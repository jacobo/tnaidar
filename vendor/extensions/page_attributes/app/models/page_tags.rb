module PageTags
  
  include Radiant::Taggable
  
  desc %{
    hi
  }
  tag 'hi' do |tag|
    out = ""
    tag.globals.page.request.params.each do
      | param |
      out += param[0].to_s + ": " + param[1].to_s + " <br/> "
    end
    out
  end

#Makes use of UploadedFilePageAttribute

  desc %{
    Renders an image tag to display the image that was uploaded for the named UploadedFilePageAttribute.

    *Usage:* 
    <pre><code><r:image attribute="" /></code></pre>
  }
  tag 'image' do |tag|
    page = tag.locals.page
    if att_name = tag.attr['attribute']
      if att = page.attribute(att_name)
        url = att.public_filename;
        options = tag.attr.dup
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" unless attributes.empty?    
        %{<img src="#{url}" #{attributes}/>}
      end
    end
  end


  desc %{
    Redirects the browser to download the uploaded file.

    *Usage:* 
    <pre><code><r:redirect_to_download attribute="" /></code></pre>
  }
  tag 'redirect_to_download' do |tag|
    page = tag.locals.page
    if att_name = tag.attr['attribute']
      if att = page.attribute(att_name)
        url = att.public_filename;
        options = tag.attr.dup
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" unless attributes.empty?    
        %{redirect_to "#{url}"}
        #raise RedirectException.redirect_to(url);
      end
    end
  end
  
  desc %{
    Renders a straight url to the file that was uplaoded for the named UploadedFilePageAttribute.
    
    *Usage:* 
    <pre><code><r:upload_url attribute="" /></code></pre>
  }
  tag 'upload_url' do |tag|
    page = tag.locals.page
    if att_name = tag.attr['attribute']
      if att = page.attribute(att_name)
        url = att.public_filename;
        options = tag.attr.dup
        attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
        attributes = " #{attributes}" unless attributes.empty?    
        %{#{url}}
      end
    end
  end


#Makes use of StringPageAttribute

  desc %{
    Renders a the value entered for the named StringPageAttribute.
    
    *Usage:* 
    <pre><code><r:string attribute="" /></code></pre>
  }
  tag 'string' do |tag|
    page = tag.locals.page
    if att_name = tag.attr['attribute']
      if att = page.attribute(att_name)
        att.value;
      end
    end
  end

#Makes use of BooleanPageAttribute

  desc %{
    Renders the containing elements if the named BooleanPageAttribute is checked-off.  
    
    Or in the case of other attributes, if the named attribute is a valid attribute.
    
    *Usage:* 
    <pre><code><r:if_att [attribute="attribute_name"]>...</r:if_att></code></pre>
  }
  tag 'if_att' do |tag|
    page = tag.locals.page    
    if att_name = tag.attr['attribute']
      if page.attribute(att_name)
        att_value = page.attribute(att_name).value;
        unless att_value.nil? or att_value == "" or att_value == false
          tag.expand
        end
      end
    end
  end
  
  desc %{
    Renders the containing elements if the named BooleanPageAttribute un-checked.  
    
    Or in the case of other attributes, if the named attribute invalid. (does not exist)
    
    *Usage:* 
    <pre><code><r:unless_att [attribute="attribute_name"]>...</r:unless_att></code></pre>
  }
  tag 'unless_att' do |tag|
    page = tag.locals.page
    if att_name = tag.attr['attribute']
      att_value = page.attribute(att_name).value;
      if att_value.nil? or att_value == "" or att_value == false
        tag.expand
      end
    else
      tag.expand
    end
  end


#Makes use of PageLinkPageAttribute
  
  desc %{
    Renders a link to the page pointed to by the named PageLinkPageAttribute.
    
    *Usage:* 
    <pre><code><r:link_att [attribute="name"] [other attributes...] /></code></pre>
    <pre><code><r:link_att>...</r:link_att></code></pre>
  }
  tag 'link_att' do |tag|
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?    
    attribute = options.delete('attribute')
    page = tag.locals.page
    page_att = page.attribute(attribute)    
    text = tag.double? ? tag.expand : page_att.link_to_page.title
    url = page_att.link_to_page.url;
    %{<a href="#{url}"#{attributes}>#{text}</a>}
  end

#Makes use of DatePageAttribute
  
  desc %{ 
    Renders the date that a page was published (or in the event that it has
    not been modified yet, the date that it was created). The format attribute
    uses the same formating codes used by the Ruby @strftime@ function. By
    default it's set to @%A, %B %d, %Y@.
   
    *Usage:*  
    <pre><code><r:date_att [format="format_string"] /></code></pre>
  }
  tag 'date_att' do |tag|
    page = tag.locals.page
    format = (tag.attr['format'] || '%A, %B %d, %Y')
    if date = page.attribute(tag.attr['attribute']).value
      date.strftime(format)
    end
  end
  
#Extension of children:each to allow ordering by attributes

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
  tag 'children:each_att' do |tag|
    options = children_find_options(tag)
    #remove limit tag from options
    if(limit = options[:limit])
      options[:limit] = nil
    end
    
    result = []
    children = tag.locals.children
    tag.locals.previous_headers = {}
    found_children = children.find(:all, options)
    
    if(by_att = tag.attr['by_att'])
      #skip pages that don't match this attribute
      found_children.reject!{ |page| page.attribute(by_att).nil? }
      found_children.sort! do
        | left , right |
        #begin #If there is a problem comparing 2 pages, just return 0 for the comparisson
        left_val = left.attribute(by_att).value
        right_val = right.attribute(by_att).value
        if(tag.attr['order'] == 'desc')
          right_val <=> left_val
        else
          left_val <=> right_val
        end
        #rescue
        #  0
        #end
      end
    end
    if limit
      found_children = found_children[0...limit]
    end
    
    found_children.each do |item|
      tag.locals.child = item
      tag.locals.page = item
      result << tag.expand
    end
    result
  end



end