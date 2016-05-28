class Attach < ApplicationRecord
  belongs_to     :user
  belongs_to     :attachable, :polymorphic => true, optional: true
  validates      :code, :filename, :filename_storage, presence: true
  validates      :code, uniqueness: true
  after_destroy  :remove_file

  class << self
    def add(filename, data, user)
      return unless data && filename && user

      fn = TmpFiles.upload data, 'files'
      create :code => fn, :filename => filename, :filename_storage => fn, :user => user if fn
    end

    def process(codes, model)
      codes.each do |key|
        item = find_by_code(key)
        next if item.nil? || item.attachable_type

        fn = item.storage.put item.code, TmpFiles.read(item.code, 'files')
        item.update :attachable => model, :filename_storage => fn, :temporary => false
      end
    end
  end

  def permit?(*opts)
    check_permissions :'permit?', *opts
  end

  def permit_modify?(*opts)
    check_permissions :'permit_modify?', *opts
  end

  def storage
    res = nil
    res = attachable.attaches_storage if attachable&.respond_to?(:attaches_storage)

    res || Attachment::FileStorage.new
  end

  def url(*opts)
    "#{Rails.application.config.attaches_url || ''}/#{filename_storage}"
  end

  private

  def check_permissions(method, *opts)
    if temporary
      user_value = Permissions.extract_user(*opts)
      user_value && user_value.id == self.user.id
    else
      attachable.respond_to?(method) && attachable.send(method, *opts)
    end
  end

  def remove_file
    storage.remove(filename_storage) unless temporary?
  end
end
