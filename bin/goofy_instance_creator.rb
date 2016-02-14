class GoofyInstanceCreator

  def initialize(app_name = nil,app_dir,current_dir)
    begin
      @app_name = app_name || (raise ArgumentError.new("No value provided for required arguments 'app_path'"))
      @app_dir = app_dir
      @current_dir = current_dir
      @target_dir = (current_dir + '/' + app_name)
      rewrite() if File.directory?(@target_dir)
    rescue ArgumentError => e
      puts e
      abort
    end
  end

  def execute!(mkdir = true)
    FileUtils.mkdir(@app_name) if mkdir
    FileUtils.copy_entry @app_dir, @target_dir

    Bundler.with_clean_env do
      Dir.chdir("#{@target_dir}") do
        system "bundle"
      end
    end
  end

  def rewrite
    puts "Do you want to rewrite '#{@app_name}'?(yes/no)"
    rs = STDIN.gets.chomp
    if rs == "yes"
      execute!(false)
      abort
    elsif rs == "no"
      abort
    else
      rewrite()
    end
  end

end
