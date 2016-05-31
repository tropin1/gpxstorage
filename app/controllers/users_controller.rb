class UsersController < RefsController
  resource_type User
  ref_options_set :ref_actions => [:index, :show, :remove, :index_items, :update]

  before_action :authenticate_user!, :except => [:show, :index, :index_items]
  before_action(:only => [:remove]) { forbidden_place unless current_user.admin? }

  def index_items
    super

    @items = @items.reorder(:id)
  end

  protected

  def permit_remove_objects?(list)
    super && !list.map(&:get_id).include?(current_user.get_id)
  end

  def resource_params
    par = params.require(resource.sm_name).permit(:name, :admin)
    par.delete :admin if @item.get_id == current_user.get_id || !current_user.admin?

    par
  end
end