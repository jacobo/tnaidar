# Much of this controller and associated fck stuff was ripped off from:
# http://trac.underpantsgnome.com/fckeditor_on_rails
# Thank you MIT License

class FckeditorController < ApplicationController
  before_filter :get_options, :sanitize_directory
  layout false

  def index
    render :nothing => true unless RAILS_ENV == 'development'
  end

  def fckstyles
    headers["Content-Type"] = "application/xml"
    render :action => 'fckstyles'
  end

  def upload
    params.each do
      | param |
      logger.debug(" -" + param.to_s + "- ");
    end
    
    upload_file(true)
  end

  def connector
    logger.debug("Connector begin: " + params.to_s);
    case params[:Command]
      when 'GetFoldersAndFiles', 'GetFolders'
        get_folders_and_files
      when 'CreateFolder'
        create_folder
      when 'FileUpload'
        upload_file
    end
    logger.debug("Connector end");
  end

private

  def get_folders_and_files
    @files = []
    @dirs = []
    
    #RADIANT_ROOT + "/" + 
    
    FileUtils.mkdir_p(@options[:dir]);
    dir = Dir.new(@options[:dir])

    dir.each do |x|
      next if x =~ /^\.\.?$/ # skip . and ..
      
      # actual file system path
      full_path = File.join(@options[:dir], x)

      # found a directory add it to the list
      if File.directory?(full_path)
        @dirs << x
      # if we only want directories, skip the files
      elsif params[:Command] == 'GetFoldersAndFiles' && File.file?(full_path)
        size = File.size(full_path)
        size = size != 0 && size < 1024 ? 1 : size / 1024
        @files << { :name => x, :size => size };
      end
    end

    render :template => 'fckeditor/files_and_folders'
  end

  # create a new directory
  def create_folder
    begin
      Dir.mkdir(File.join(@options[:dir], params[:NewFolderName]))
    rescue Errno::EEXIST
      # directory already exists
      @error = 101
    rescue Errno::EACCES
      # permission denied
      @error = 103
    rescue
      # any other error
      @error = 110
    end
    render :template => 'fckeditor/create_folder'
  end

  # upload a new file
  # currently the FCKeditor docs only allow for 2 errors here
  # file renamed and invalid file name
  # not sure how to catch invalid file name yet
  # I'm thinking there should be a permission denied error as well
  def upload_file(quick_upload = false)
    counter = 1
    @file_name = params[:NewFile].original_filename
    # break it up into file and extension
    # we need this to check the types and to build new names if necessary
    ext = File.extname(@file_name)
    path = File.basename(@file_name, ext)

    # check to make sure this extension isn't in deny and is in allow
    filetype = params[:Type].downcase.to_sym
    if type_allowed(filetype, ext)
      while File.exist?(File.join(@options[:dir], @file_name))
        @file_name = "#{path}(#{counter})#{ext}"
        @error = 201
        counter += 1
      end

      File.open("#{@options[:dir]}#{@file_name}", 'wb') do |f| 
        f.write(params[:NewFile].read)
      end
    else
      # invalid file type
      @error = 202
    end
    
    if quick_upload
      render :template => 'fckeditor/quick_upload_file'
    else
      render :template => 'fckeditor/upload_file'
    end
  end

  def type_allowed(filetype, ext)
#    type = Fckeditor.config[:file_types][filetype]
    
#    (! type[:deny] || ! type[:deny].include?(ext)) &&
#      (! type[:allow] || type[:allow].include?(ext))

    #Simply allowing all types
    return true;
  end

  def get_options
    @error = 0
    @options = {}
    @options[:url] = "/#{Fckeditor.config[:upload_dir]}/#{params[:Type]}/#{params[:CurrentFolder]}".gsub(/\/+/, '/')
    @options[:dir] = File.join(RAILS_ROOT, 'public', @options[:url])
    logger.debug("@options[:url]: " + @options[:url]);
    logger.debug("@options[:dir]: " + @options[:dir]);      
  end
  
  def sanitize_directory
    if params[:CurrentFolder]
      clean = File.expand_path(File.join(RAILS_ROOT, 'public', Fckeditor.config[:upload_dir]))
      dirty = File.expand_path(@options[:dir])
      logger.debug("dirty: " + dirty);
      logger.debug("clean: " + clean);      
      unless dirty.starts_with?(clean)
        render :nothing => true, :status => 403
        false
      end
    end
  end
  
end
