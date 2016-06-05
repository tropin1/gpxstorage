module Attachment
  module Attachable
    def attaches
      if attaches_cached?
        Attach.where(:code => @attach_cache)
      else
        super
      end
    end

    def attaches_cached?
      !@attach_cache.nil?
    end

    def attaches=(value)
      @attach_cache ||= []
      @attach_cache += value
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