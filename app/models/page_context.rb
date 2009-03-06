class PageContext < Radius::Context

    
  attr_reader :page
  
  def initialize(page)
    super()
    
    @page = page
    globals.page = @page
    
    page.tags.each do |name|
      define_tag(name) { |tag_binding| page.render_tag(name, tag_binding) }
    end
  end
 
  def render_tag(name, attributes = {}, &block)
    super
  rescue Exception => e
    raise e if testing?
    logger = Logger.new(STDERR)
    logger.print_stack_trace(e)
    render_error_message(e.message)
  end
  
  def tag_missing(name, attributes = {}, &block)
    super
  rescue Radius::UndefinedTagError => e
    raise StandardTags::TagError.new(e.message)
  end
  
  private
  
    def render_error_message(message)
      "<div><strong>#{message}</strong></div>"
    end
    
    def testing?
      RAILS_ENV == 'test'
    end
    
end
