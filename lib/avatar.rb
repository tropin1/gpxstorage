module Attachment
  module Avatar
    def self.included(base)
      base.belongs_to :avatar, dependent: :destroy, foreign_key: 'avatar_id', class_name: 'Attach', optional: true
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
        self.avatar = Attach.find_by_code(value)
      end
    end
  end
end