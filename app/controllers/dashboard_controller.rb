class DashboardController < ApplicationController
  def index

  end

  def search
    redirect_to :controller => :tracks, :action => :index, :text => params[:search_text]
  end

end
