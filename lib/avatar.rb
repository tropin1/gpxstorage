module Attachment
  module Avatar
    def self.included(base)
      base.belongs_to :avatar, dependent: :destroy, foreign_key: 'avatar_id', class_name: 'Attach'
    end

    def avatar_code
      avatar&.code || 'empty'
    end

    def avatar_url
      avatar&.url
    end

    def avatar_code=(value)
      if value.to_s.empty? || value == 'empty'
        self.avatar = nil
      else
        item = attachments.where(:code => value).first

        unless item
          item = Attachment.find_by_code(value)
          raise "attachment #{value} already in use" unless item && item.attachable_id.nil?

          self.attachments = [value]
        end

        self.avatar = item
      end
    end
  end
end