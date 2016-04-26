class RefsController < ApplicationController
  include LibSupport::RefsController

  def permission_params
    super.merge :user => current_user
  end

end