class TracksController < RefsController
  resource_type Track

  before_action :only => [:index, :index_items] do
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
  end

  before_filter :only => [:show] do
    redirect_to root_path unless @item.permit_modify?(permission_params)
  end

  def index_items
    super

    @items = @items.where(:user_id => @user.id) if @user
  end

  def url_scope(action)
    "/users/#{params[:user_id]}" if action == :index_items && params[:user_id]
  end

  protected

  def resource_params
    params.require(resource.sm_name).permit(:name, :descr, :public)
  end

  def update_resource(options = {})
    @item.user ||= current_user

    super
  end
end
