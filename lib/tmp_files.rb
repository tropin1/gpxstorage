module TmpFiles
  class << self
    def gen_hex
      SecureRandom.hex(26)
    end

    def pack(name, track_items)
      dir = Rails.root.join('tmp', 'packs', gen_hex)
      FileUtils::mkdir_p dir

      files = []
      track_items.each do |item|
        fn = dir.join("#{Zaru.sanitize!(item.name)}.gpx")
        File.write fn, item.data
        files << fn
      end

      fn = "#{Zaru.sanitize!(name)}.7z"
      system("cd #{dir} && 7za a \"#{fn}\" -mx9 #{files.map{|x| "\"#{x}\"" }.join(' ')}") || return

      res = [ {:name => fn, :content => File.read(dir.join(fn))} ]
      FileUtils::rm_rf dir

      res
    end

    def read(item_code, folder = 'tracks')
      dir = Rails.root.join('tmp', folder)
      fn = dir.join("#{item_code}.tmp")

      if File.exist?(fn) && (data = File.read(fn))
        File.delete(fn)
        Dir.delete(dir) if Dir["#{dir}/*"].empty?

        data
      end
    end

    def upload(data, folder = 'tracks')
      fn, dir = gen_hex, Rails.root.join('tmp', folder)

      fn if FileUtils::mkdir_p(dir) && File.open(dir.join("#{fn}.tmp"), 'wb') {|f| f.write(data) }
    end
  end
end