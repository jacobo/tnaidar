class Admin::ConfigController < ApplicationController
  
  def index
    @configs = Radiant::Config.to_hash;
  end
  
  def save
    Radiant::Config.find(:all).each{ |entry| entry.destroy }
    params[:key].each do
      | index, key |
      unless key.empty?
        Radiant::Config[key] = params[:value][index]
      end
    end
    redirect_to :action => 'index'
  end
  
  def set
    Radiant::Config[params[:key]] = params[:value]
    redirect_to :back
  end
  
end