module TmpFiles
  class << self
    def pack(name, track_items)
      dir = Rails.root.join('tmp', 'packs', SecureRandom.hex(26))
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

    def read(item_code)
      dir = Rails.root.join('tmp', 'tracks')
      fn = dir.join("#{item_code}.tmp")

      if File.exist?(fn) && (data = File.read(fn))
        File.delete(fn)
        Dir.delete(dir) if Dir["#{dir}/*"].empty?

        data
      end
    rescue
      nil
    end

    def upload(data)
      fn, dir = SecureRandom.hex(26), Rails.root.join('tmp', 'tracks')
      FileUtils::mkdir_p dir
      File.open(dir.join("#{fn}.tmp"), 'wb') {|f| f.write data }

      fn
    rescue
      nil
    end
  end
end