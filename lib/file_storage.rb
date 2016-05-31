module Attachment
  class FileStorage
    attr_accessor :options

    def default_options
      { :path => Rails.application.config.attaches_path.to_s }
    end

    def get(fn)
      full_fn = "#{options.path}/#{fn}"
      File.read(full_fn) if File.exists?(full_fn)
    end

    def initialize(*args)
      self.options = args.extract_options!.dup
    end

    def options
      @options.methods_for_keys
    end

    def options=(value)
      @options ||= default_options
      @options.merge!(value)
    end

    def put(code, data)
      fn = gen_filename(code)
      File.open("#{options.path}/#{fn}", 'wb') {|f| f.write data } if fn

      fn
    end

    def remove(fn)
      full_fn = "#{options.path}/#{fn}"
      File.exists?(full_fn) && File.delete(full_fn)
    end

    protected

    def gen_filename(code)
      nn = Time.now
      dir = "#{nn.strftime('%Y')}/#{nn.strftime('%m').rjust(2, '0')}"

      "#{dir}/#{nn.strftime('%Y_%m_%d_%H_%M_%S')}-#{code}.data" if mkdir_p_inner(dir)
    end

    def mkdir_p_inner(dir)
      FileUtils::mkdir_p("#{options.path}/#{dir}")
    end
  end
end