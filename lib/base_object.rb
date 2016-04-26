module BaseObject

  module ClassMethods
    def default_values
      result = @default_values || {}

      @default_values_procs.each {|k, v| result.merge! k => v.call } if @default_values_procs
      result
    end

    # full text search
    def find_object(txt, params = {})
      text = txt.strip
      where(params).where("txt_index @@ plainto_tsquery(unaccent($$#{text}$$))").order("ts_rank(txt_index, plainto_tsquery($$#{text}$$)) desc, name <-> $$#{text}$$")
    end

    def form_columns
      @form_columns || ref_columns
    end

    def permitted_for(*opts)
      all
    end

    def ref_columns
      @ref_columns || [:name]
    end

    def remove_def_value_for(attribute)
      @default_values.except!(attribute) if @default_values
      @default_values_procs.except!(attribute) if @default_values_procs
    end

    def set_default_value(attribute, &block)
      @default_values_procs ||= {}
      @default_values_procs.merge! attribute.to_sym => block
    end

    def set_default_values(values)
      @default_values ||= {}
      @default_values.merge! values
    end

    def set_form_columns(*list)
      @form_columns = list.to_a
    end

    def set_ref_columns(*list)
      @ref_columns = list.to_a
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  # value to html value
  def ref_column_value(name)
    send(name).to_s.html_safe
  end

  # permission for view
  def permit?(*opts)
    true
  end

  # permission for modify and remove
  def permit_modify?(*opts)
    true
  end
end