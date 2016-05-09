module TmpFiles
  class << self
    def upload(code, data)
      fn, dir = "#{SecureRandom.hex(26)}.tmp", Rails.root.join('tmp', code)
      FileUtils::mkdir_p dir

      File.open(dir.join(fn), 'wb') {|f| f.write data }
      fn
    ensure

    end
  end
end