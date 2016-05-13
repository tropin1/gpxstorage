class UsersController < RefsController
  resource_type User
  ref_options_set :ref_actions => [:index, :show, :remove, :index_items, :update], :url_scope => '/admin'

  before_action :authenticate_user!, :except => [:show, :index, :index_items]
  before_action(:except => [:show, :update, :index, :index_items]) do
    redirect_to root_path unless current_user.admin?
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