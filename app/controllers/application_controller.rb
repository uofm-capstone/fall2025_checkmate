class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_semesters

  # Catch all CanCanCan AccessDenied errors
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        flash[:alert] = "You are not authorized to access this page."
        redirect_to root_path
      end
      format.json { render json: { error: "You are not authorized to access this page." }, status: :forbidden }
      format.js { head :forbidden }
    end
  end

  private

  def set_semesters
    @semesters = Semester.all
  end
end
