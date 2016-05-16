class TracksController < RefsController
  resource_type Track
  layout false, :only => :upload

  before_action :only => [:index, :index_items] do
    @user = User.find_by_id(params[:user_id]) if params[:user_id]
  end

  before_action :only => [:show] do
    redirect_to root_path unless @item.permit_modify?(permission_params)
  end

  before_action :only => [:gpx, :view, :download] do
    @item = resource.find_by_code(params[:track_code])

    respond_to do |format|
      format.js { render body: nil, status: :not_found }
      format.html { redirect_to root_path }
    end unless @item && @item.permit?(permission_params)
  end

  def download
    UserMailer.delay.download_track current_user.id, @item.code
  end

  def gpx
    item = @item.track_items.where(:id => params[:id]).first

    if item
      render xml: item.data
    else
      render body: nil, status: :not_found
    end
  end

  def index_items
    super

    @items = @items.reorder(:created_at => :desc)
    @items = @items.where(:user_id => @user.id) if @user
  end

  def view

  end

  def upload
    render body: nil, status: :unprocessable_entity unless request.content_length <= Rails.application.config.max_attach_size &&
        (@code = TmpFiles.upload(request.raw_post))
  end

  def url_scope(action)
    "/users/#{params[:user_id]}" if action == :index_items && params[:user_id]
  end

  protected

  def resource_params
    params.require(resource.sm_name).permit(:name, :descr, :public, :layer_id, :track_items => [:name, :code, :color, :update_id])
  end

  def update_resource(options = {})
    @item.user ||= current_user

    super
  end
end
