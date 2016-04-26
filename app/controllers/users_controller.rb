class UsersController < RefsController
  resource_type User
  ref_options_set :ref_actions => [:index, :show, :remove, :index_items]

  protected

  def resource_params
    params.require(resource.sm_name).permit(:name)
  end
end