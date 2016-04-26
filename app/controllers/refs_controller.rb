class RefsController < ApplicationController
  include RefsControllerModule

  def permission_params
    super.merge :user => current_user
  end

end