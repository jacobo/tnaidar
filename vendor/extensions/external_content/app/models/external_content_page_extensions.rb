require 'net/http'
require 'uri'

module ExternalContentPageExtensions

    include Radiant::Taggable

    desc %{
      external content
      
      *Usage:* 
      <pre><code><r:external_content url="" /></code></pre> 
    }
    tag 'external_content' do |tag|
      if url = tag.attr['url']
        Net::HTTP.get URI.parse(url.to_s)
        #{}"External Content goes here... " + url.to_s        
      end
      # out = ""
      # tag.globals.page.request.params.each do
      #   | param |
      #   out += param[0].to_s + ": " + param[1].to_s + " <br/> "
      # end
      # out
    end


end