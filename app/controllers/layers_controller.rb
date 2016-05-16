class LayersController < RefsController
  resource_type Layer
  ref_options_set :url_scope => '/admin'

  before_action :authenticate_user!
  before_filter do
    respond_to do |format|
      format.js { render body: nil, status: :not_found }
      format.html { redirect_to root_path }
    end unless current_user.admin?
  end

  protected

  def resource_params
    params.require(resource.sm_name).permit(:name, :url)
  end
end
