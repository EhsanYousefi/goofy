module GoofyGenerator

  class Base

    def initialize(type,name)
      begin
        @type = type || (raise ArgumentError.new("You must specify type for generator, for example: goofy g resource"))
        @name = name.split(/\//).delete_if { |x| x == "" } if name
        raise ArgumentError.new("You must specify name for generator, for example: goofy g resource home") unless name
      rescue ArgumentError => e
        puts e
        abort
      end
    end

    def execute!
      type_mapper
    end

    def type_mapper
      begin
        case @type
          when "controller"
            GoofyGenerator::Controller.new(@name).execute!
          when "service"
            GoofyGenerator::Service.new(@name).execute!
          when "resource"
            GoofyGenerator::Controller.new(@name).execute!
            GoofyGenerator::Service.new(@name).execute!
          when "initializer"
            GoofyGenerator::Initializer.new(@name).execute!
          else
            raise ArgumentError.new("Invalid generator, Valid generators resource / controller / service")
        end
      rescue ArgumentError => e
        puts e
        abort
      end
    end

  end

  class Initializer

    def initialize(name)
      @name = name
      @init_path = 'config/initializers'
      @config_path = 'config/'
    end

    def execute!
      FileUtils.mkdir_p(@init_path)
      create_files
    end

    def create_files
      create_init(
        file_name: @name.first,
        path: @init_path
      )
      create_config(
        file_name: @name.first,
        path: @config_path
      )
    end

    def ask_to_rewrite(file_path, &block)
      if File.exist?(file_path)
        puts "Already exists: #{file_path}"
      else
        block.call
        puts "File created: #{file_path}"
      end
    end

    def create_init(hash = {})
      file_name = hash[:file_name] + '.rb'
      file_path = if hash[:path][-1] == '/'
                    (hash[:path] + file_name)
                  else
                    (hash[:path] + '/' + file_name)
                  end
      ask_to_rewrite(file_path) do
        file = File.open(file_path, "a+")
        file.puts("# require 'yaml'")
        file.puts("# YAML::load_file(File.join(ENV[\"PWD\"], \"/config\",\"/#{hash[:file_name]}.yml\"))")
        file.close()
      end
    end

    def create_config(hash = {})
      file_name = hash[:file_name] + '.yml'
      file_path = if hash[:path][-1] == '/'
                    (hash[:path] + file_name)
                  else
                    (hash[:path] + '/' + file_name)
                  end
      ask_to_rewrite(file_path) do
        file = File.open(file_path, "a+")
        file.puts("# automatically generated config file for #{hash[:file_name]} initializer")
        file.close()
      end
    end

  end

  class Controller

    def initialize(name)
      @name = name
      @path = 'app/controllers/'
    end

    def execute!
      FileUtils.mkdir_p(@path + @name[0..-2].join('/')) if @name.size > 1
      create_files
    end

    def create_files
      @name.each_with_index do |item, index|
        if index == 0
          create_class(
            file_name: item,
            path: @path,
            class_name: gen_class_name([item]),
            super_class_name: 'ApplicationController'
          )
        else
          create_class_with_module(
            file_name: item,
            path: @path + @name[0,index].join('/'),
            class_name: gen_class_name(@name[0, index + 1]),
            file_header: generate_module_name_header(@name[0,index]),
            file_footer: generate_module_name_footer(@name[0,index]),
            super_class_name: gen_class_name(@name[0,(index)]),
            name_index: @name[0,index]
            )
        end
      end
    end

    def generate_module_name_header(list)
      str = ""
      list.each_with_index do |item, index|
        if index == 0
          str += "module #{item.capitalize}\n"
        else
          str += (" " * (2 * index)) + "module #{item.capitalize}\n"
        end
      end
      str
    end

    def generate_module_name_footer(list)
      arr = (0..list.size - 1).to_a.reverse
      str = ""
      arr.each do |item|
        if item == arr.last
          str += "end\n"
        else
          str += (" " * (2 * item)) + "end\n"
        end
      end
      str
    end

    def ask_to_rewrite(file_path, &block)
      if File.exist?(file_path)
        puts "Already exists: #{file_path}"
      else
        block.call
        puts "File created: #{file_path}"
      end
    end

    def create_class(hash = {})
      file_name = hash[:file_name] + '_controller.rb'
      file_path = if hash[:path][-1] == '/'
                    (hash[:path] + file_name)
                  else
                    (hash[:path] + '/' + file_name)
                  end
      ask_to_rewrite(file_path) do
        file = File.open(file_path, "a+")
        file.puts("class #{hash[:class_name]} < #{hash[:super_class_name]}")
        file.puts("  # def response")
        file.puts("  # end")
        file.puts("end")
        file.close()
      end
    end

    def create_class_with_module(hash = {})
      file_name = hash[:file_name] + '_controller.rb'
      file_path = if hash[:path][-1] == '/'
                    (hash[:path] + file_name)
                  else
                    (hash[:path] + '/' + file_name)
                  end
      ask_to_rewrite(file_path) do
        file = File.open(file_path, "a+")
        file.puts(hash[:file_header]) if hash[:file_header]
        file.puts(correct_indent("class #{hash[:class_name]} < #{hash[:super_class_name]}", hash[:name_index]))
        file.puts(correct_indent("  # def response", hash[:name_index]))
        file.puts(correct_indent("  # end", hash[:name_index]))
        file.puts(correct_indent("end", hash[:name_index]))
        file.puts(hash[:file_footer]) if hash[:file_footer]
        file.close()
      end
    end

    def correct_indent(string, name)
      size = name.size
      (" " * (2 * size)) + string
    end

    def gen_class_name(name)
      name.last.capitalize + 'Controller'
    end

    def gen_module_name(name)
      count = name.count - 1
      name.map.with_index do |item, index|
        if index == count
          item.capitalize
        else
          item.capitalize + '::'
        end
      end
    end

  end

  class Service

    def initialize(name)
      @name = name
      @path = 'app/services/'
    end

    def execute!
      FileUtils.mkdir_p(@path + @name[0..-2].join('/')) if @name.count > 1
      create_files
    end

    def create_files
      @name.each_with_index do |item, index|
        if @name.size == 1
          create_class(
            file_name: item,
            path: @path,
            class_name: gen_class_name([item]),
          )
        elsif index == (@name.size - 1)
          create_class_with_module(
            file_name: item,
            path: @path + @name[0,index].join('/'),
            class_name: gen_class_name(@name[0, index + 1]),
            file_header: generate_module_name_header(@name[0,index]),
            file_footer: generate_module_name_footer(@name[0,index]),
            name_index: @name[0,index]
            )
        end
      end
    end

    def generate_module_name_header(list)
      str = ""
      list.each_with_index do |item, index|
        if index == 0
          str += "module #{item.capitalize}\n"
        else
          str += (" " * (2 * index)) + "module #{item.capitalize}\n"
        end
      end
      str
    end

    def generate_module_name_footer(list)
      arr = (0..list.size - 1).to_a.reverse
      str = ""
      arr.each do |item|
        if item == arr.last
          str += "end\n"
        else
          str += (" " * (2 * item)) + "end\n"
        end
      end
      str
    end

    def ask_to_rewrite(file_path, &block)
      if File.exist?(file_path)
        puts "Already exists: #{file_path}"
      else
        block.call
        puts "File created: #{file_path}"
      end
    end

    def create_class(hash = {})
      file_name = hash[:file_name] + '_service.rb'
      file_path = if hash[:path][-1] == '/'
                    (hash[:path] + file_name)
                  else
                    (hash[:path] + '/' + file_name)
                  end
      ask_to_rewrite(file_path) do
        file = File.open(file_path, "a+")
        file.puts("class #{hash[:class_name]}")
        file.puts("  include Wisper::Publisher")
        file.puts("end")
        file.close()
      end
    end

    def create_class_with_module(hash = {})
      file_name = hash[:file_name] + '_service.rb'
      file_path = if hash[:path][-1] == '/'
                    (hash[:path] + file_name)
                  else
                    (hash[:path] + '/' + file_name)
                  end
      ask_to_rewrite(file_path) do
        file = File.open(file_path, "a+")
        file.puts(hash[:file_header]) if hash[:file_header]
        file.puts(correct_indent("class #{hash[:class_name]}", hash[:name_index]))
        file.puts(correct_indent("  include Wisper::Publisher", hash[:name_index]))
        file.puts(correct_indent("end", hash[:name_index]))
        file.puts(hash[:file_footer]) if hash[:file_footer]
        file.close()
      end
    end

    def correct_indent(string, name)
      size = name.size
      (" " * (2 * size)) + string
    end

    def gen_class_name(name)
      name.last.capitalize + 'Service'
    end

    def gen_module_name(name)
      count = name.count - 1
      name.map.with_index do |item, index|
        if index == count
          item.capitalize
        else
          item.capitalize + '::'
        end
      end
    end

  end

end
