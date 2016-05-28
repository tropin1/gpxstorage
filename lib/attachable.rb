module Attachment
  module Attachable
    def attaches
      if @attach_cache
        Attach.where(:code => @attach_cache.to_a.map(&:first))
      else
        super
      end
    end

    def attaches=(value)
      @attach_cache = value
    end

    def self.included(base)
      base.has_many       :attaches, -> { order img: :desc, created_at: :asc }, dependent: :destroy, as: :attachable
      base.after_save     :pin_attachments
    end

    def pin_attachments
      return unless @attach_cache

      Attach.process(@attach_cache, self)
      @attach_cache = nil
    end
  end
end