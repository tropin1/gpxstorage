class Attach < ApplicationRecord
  belongs_to     :user
  belongs_to     :attachable, :polymorphic => true, optional: true
  validates      :code, :filename, :filename_storage, presence: true
  validates      :code, uniqueness: true
  after_destroy  :remove_file

  class << self
    def add(filename, data, user)
      return unless data && filename && user

      attach = new(:filename => filename, :user => user, :code => TmpFiles.gen_hex)
      attach.filename_storage = attach.storage.put(attach.code, data)

      attach.save
      attach
    end

    def process(codes, model)
      codes.each do |key|
        item = find_by_code(key)
        next if item.nil? || item.attachable_type

        item.update :attachable => model, :temporary => false
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
    storage.remove(filename_storage)
  end
end
