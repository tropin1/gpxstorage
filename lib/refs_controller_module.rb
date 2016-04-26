module RefsControllerModule

  module ClassMethods
    def ref_options_set(val)
      self.ref_options = self.ref_options.merge(val)
    end

    def resource_type(val)
      self.resource = val
    end
  end

  def create
    par = resource_params
    @item = create_resource(par) unless @item

    unless permit_modify_object?(@item)
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html { redirect_to(:action => 'index') }
      end

      return
    end

    after_change 'new', update_resource(par)
  end

  def index

  end

  def index_items
    @page = params[:page].to_i
    @page = 1 if @page < 1

    @items = resource.permitted_for(permission_params).order("#{resource.table_name}.id desc").page(@page)
  end

  def new
    @item = resource.new
    @item.assign_attributes resource.default_values
  end

  def permission_params
    {}
  end

  def ref_action?(action)
    list = ref_options[:ref_actions] || ActionDispatch::Routing::Mapper::REF_ACTIONS
    list.include?(action)
  end

  def remove
    par = "#{resource.sm_name}_remove_ids".to_sym
    list = resource.where(:id => params[par].to_s.split(',').map(&:to_i))

    ids = list.map(&:get_id)
    render json: { :remove_list => [remove_error_msg(list)] }, status: :forbidden and return unless permit_remove_objects?(list)

    resource.transaction do
      list.each do |x|
        name = x.name
        unless x.destroy
          errors = x.errors.inject({}) {|result, (k, v)| result.merge(k.to_sym => [ "#{name}: #{v}" ]) }

          render json: errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end

      render json: ids
    end
  end

  def show
    @item = resource.find_by_id(params[:id])

    respond_to do |format|
      format.js do
        render nothing: true, status: :not_found and return unless @item && @item.permit?(permission_params)
        render json: @item
      end

      format.html { redirect_to :action => 'index' unless @item && @item.permit?(permission_params) }
    end
  end

  def update
    @item = resource.find_by_id(params[:id]) unless @item

    unless @item && permit_modify_object?(@item)
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html { redirect_to(:action => 'index') }
      end

      return
    end

    after_change 'show', update_resource(resource_params)
  end

  protected

  def action_after_change
    { :action => :index }
  end

  def after_change(action, result)
    respond_to do |format|
      format.json do
        if result
          render json: serialize_params(@item, resource_params)
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      format.html do
        if result
          redirect_to action_after_change
        else
          render action
        end
      end
    end
  end

  def create_resource(params)
    resource.new(resource.default_values)
  end

  def self.included(base)
    base.extend(ClassMethods)

    base.class_attribute :resource, instance_writer: false
    base.class_attribute :ref_options, instance_writer: false

    base.resource = ActiveRecord::Base
    base.ref_options = {}
  end

  def permit_modify_object?(obj)
    obj.permit_modify?(permission_params)
  end

  def permit_remove_objects?(list)
    res = list.any?
    return false unless res

    index = 0
    while res && index < list.count
      res = permit_modify_object?(list[index])
      index += 1
    end

    res
  end

  def remove_error_msg(list)
    #I18n.t('not_found')%[resource.model_name.human]
    'remove_error_msg'
  end

  def resource_params
    {}
  end

  def serialize_params(item, params)
    params.inject({}) {|vl, (key,_)| item.respond_to?(key) ? vl.merge({ key => item.send(key) }) : vl }
  end

  def update_resource(options = {})
    @item.update options
  end

end