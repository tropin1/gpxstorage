class TracksController < RefsController
  resource_type Track

  protected

  def resource_params
    params.require(resource.sm_name).permit(:name, :descr, :public)
  end

  def update_resource(options = {})
    @item.user ||= current_user

    super
  end
end
