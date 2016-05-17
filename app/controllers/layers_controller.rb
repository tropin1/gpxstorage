class LayersController < RefsController
  resource_type Layer
  ref_options_set :url_scope => '/admin'

  before_action :authenticate_user!
  before_action { forbidden_place unless current_user.admin? }

  protected

  def resource_params
    params.require(resource.sm_name).permit(:name, :url)
  end
end
