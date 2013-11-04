module Kernel
  def save_json(obj, path=nil)
    path = Pathname.new(path) unless path.nil?
    json = Oj.dump(obj, object:true, circular:true)
    path = path.sub_ext('json') unless path.nil?
    path = UnixTree.get_path(path, require: :file, new: true)
    if path
      path = path.sub_ext('json') unless path.nil?
      puts TColor.green{"writing json to #{path.to_s}..."}
      File.open(path, 'w'){|f| f.write(json)}
      true
    else
      false
    end
  end

  def load_json(path=nil)
    path = UnixTree.get_path(path, require: :file)
    if path
      puts TColor.green{"loading json from #{path.to_s}..."}
      Oj.load(path)
    else
      nil
    end
  end
  
end

module UnixTree
  class << self
    def get_path(path, opts={})
      path = Pathname.new(path) unless path.nil?
      while path.nil? || !viable_path(path, opts) do
        missing = nil
        path.expand_path.descend{|p| unless p.exist?; missing = p; break; end} if path      
        if missing
          what = (missing == path) ? opts[:require].to_s : 'directory'
          puts TColor.red{ "couldn't find #{what} #{missing.to_s}" } 
          missing = missing.dirname
          print_tree missing

        end 
        print TColor.yellow{ "enter path: "}
        in_path = $stdin.gets.chomp
        return nil if in_path == 'q'
        unless in_path.blank?
          in_path = Pathname(in_path)
          path = missing if missing
          path ||= Pathname.getwd
          path = in_path.relative? ? path.join(in_path) : in_path
        end
      end   
      path.expand_path
    end

    def viable_path(path, opts={})
      path = Pathname(path) unless path.is_a?(Pathname)
      if opts[:new]
        return false unless path.dirname.expand_path.exist?
      else
        return false unless path.expand_path.exist?
      end
      case opts[:require]
      when :file
        opts[:new] ? !(path.exist? && path.directory?) : path.expand_path.file?
      when :directory
        opts[:new] ? !path.exist? : path.expand_path.directory?
      else
        true
      end
    end

    def print_tree(path=nil)
      path ||= Pathname.getwd
      path = Pathname.new(path) unless path.is_a?(Pathname)
      path = path.dirname if path.file?
      puts TColor.blue{ "listing #{path}..."}
      puts `cd #{path.expand_path.to_s}; tree`.gsub(%r{(^[^\w]+)}, TColor.black{'\1'})
    end
  end
end