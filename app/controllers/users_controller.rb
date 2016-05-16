class UsersController < RefsController
  resource_type User
  ref_options_set :ref_actions => [:index, :show, :remove, :index_items, :update]

  before_action :authenticate_user!, :except => [:show, :index, :index_items]
  before_action(:only => [:remove]) do
    respond_to do |format|
      format.js { render body: nil, status: :not_found }
      format.html { redirect_to root_path }
    end unless current_user.admin?
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