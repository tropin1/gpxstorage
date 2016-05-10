module TmpFiles
  class << self
    def read(track_code, item_code)
      dir = Rails.root.join('tmp', 'tracks', track_code)
      fn = dir.join("#{item_code}.tmp")

      if File.exist?(fn) && (data = File.read(fn))
        File.delete(fn)
        Dir.delete(dir) if Dir["#{dir}/*"].empty?

        data
      end
    rescue
      nil
    end

    def upload(code, data)
      fn, dir = SecureRandom.hex(26), Rails.root.join('tmp', 'tracks', code)
      FileUtils::mkdir_p dir
      File.open(dir.join("#{fn}.tmp"), 'wb') {|f| f.write data }

      fn
    rescue
      nil
    end
  end
end