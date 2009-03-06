module Admin::ContentHelper
  
  include Admin::PageHelper

  def render_node(page, locals = {})
    locals.reverse_merge!(:level => 0, :simple => false).merge!(:page => page)
    render :partial => 'node', :locals =>  locals
#    render :partial => 'admin/page/node', :locals =>  locals
  end

end
