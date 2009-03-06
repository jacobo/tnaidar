class Admin::ExtensionController < ApplicationController
  def index
    @extensions = Radiant::Extension.descendants.sort_by { |e| e.extension_name }
  end
  
  def update
    Radiant::ExtensionLoader.reactivate(params[:enabled_extensions] || [])
    redirect_to :action => 'index'
  end
end
