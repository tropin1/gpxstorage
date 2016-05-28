class RefsController < ApplicationController
  include LibSupport::RefsController

  def forbidden_place
    respond_to do |format|
      format.js { render body: nil, status: :not_found }
      format.html { redirect_to root_path }
    end
  end

  def permission_params
    super.merge :user => current_user
  end

end