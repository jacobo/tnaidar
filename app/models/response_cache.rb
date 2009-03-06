class ResponseCache
  include ActionController::Benchmarking::ClassMethods
  
  @@defaults = {
    :directory => ActionController::Base.page_cache_directory,
    :expire_time => 5.minutes,
    :default_extension => '.yml',
    :perform_caching => true,
    :logger => ActionController::Base.logger,
    :use_x_sendfile => false
  }
  cattr_accessor :defaults
  
  attr_accessor :directory, :expire_time, :default_extension, :perform_caching, :logger, :use_x_sendfile
  alias :page_cache_directory :directory
  alias :page_cache_extension :default_extension
  private :benchmark, :silence, :page_cache_directory,
    :page_cache_extension 
    
  # Creates a ResponseCache object with the specified options.
  #
  # Options are as follows:
  # :directory         :: the path to the temporary cache directory
  # :expire_time       :: the number of seconds a cached response is considered valid (defaults to 5 min)
  # :default_extension :: the extension cached files should use (defaults to '.yml')
  # :perform_caching   :: boolean value that turns caching on or off (defaults to true)
  # :logger            :: the application logging object (defaults to ActionController::Base.logger)
  # :use_x_sendfile    :: use X-Sendfile headers to speed up transfer of cached pages (not available on all web servers)
  # 
  def initialize(options = {})
    options = options.symbolize_keys.reverse_merge(defaults)
    self.directory         = options[:directory]
    self.expire_time       = options[:expire_time]
    self.default_extension = options[:default_extension]
    self.perform_caching   = options[:perform_caching]
    self.logger            = options[:logger]
    self.use_x_sendfile    = options[:use_x_sendfile]
  end
  
  # Caches a response object for path to disk.
  def cache_response(path, response)
    path = clean(path)
    write_response(path, response)
    response
  end
  
  # If perform_caching is set to true, updates a response object so that it mirrors the
  # cached version.
  def update_response(path, response)
    if perform_caching
      path = clean(path)
      read_response(path, response)
    end
    response
  end
  
  # Returns true if a response is cached at the specified path.
  def response_cached?(path)
    path = clean(path)
    name = "#{page_cache_path(path)}.yml"
    File.exists?(name) and not File.directory?(name) and not (File.stat(name).mtime < (Time.now - @expire_time))
  end
    
  # Expires the cached response for the specified path.
  def expire_response(path)
    path = clean(path)
    expire_page(path)
  end
  
  # Expires the entire cache.
  def clear
    Dir["#{directory}/*"].each do |f|
      FileUtils.rm_rf f
    end
  end
  
  # Returns the singleton instance for an application.
  def self.instance
    @@instance ||= new
  end
  
  private
    # Construct the filename for the file in the cache directory for path    
    # This DOES NOT include the extension
    def page_cache_file(path)
      name = ((path.empty? || path == "/") ? "/index" : URI.unescape(path))
    end
    
    # Ensures that path begins with a slash and remove extra slashes.
    def clean(path)
      path = path.gsub(%r{/+}, '/')
      %r{^/?(.*?)/?$}.match(path)
      "/#{$1}"
    end
    
    # Reads a cached response from disk and updates a response object.
    def read_response(path, response)
      file_path = page_cache_path(path)
      content = File.open("#{file_path}.yml","rb") { |f| f.read } if response_cached?(path)
      if content
        metadata = YAML::load(content)
        response.headers.merge!(metadata['headers'] || {})
	if use_x_sendfile
	  response.headers.merge!('X-Sendfile' => "#{file_path}.data")
	else
          response.body = File.open("#{file_path}.data", "rb") {|f| f.read}
	end
      end
      response
    end
    
    # Writes a response to disk.
    def write_response(path, response)
      metadata = {
        'headers' => response.headers,
      }.to_yaml
      cache_page(metadata, response.body, path)
    end

    def page_cache_path(path)
      page_cache_directory + page_cache_file(path)
    end

    def expire_page(path)
      return unless perform_caching

      path = page_cache_path(path)
      benchmark "Expired page: #{path}" do
        File.delete("#{path}.yml") if File.exists?("#{path}.yml")
        File.delete("#{path}.data") if File.exists?("#{path}.data")
      end
    end

    def cache_page(metadata, content, path)
      return unless perform_caching

      path = page_cache_path(path)
      benchmark "Cached page: #{path}" do
        FileUtils.makedirs(File.dirname(path))
        File.open("#{path}.yml", "wb+") { |f| f.write(metadata) }
        File.open("#{path}.data", "wb+") { |f| f.write(content) }
      end
    end
end
