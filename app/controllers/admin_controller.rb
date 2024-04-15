class AdminController < ApplicationController

  def dashboard
    @semesters = Semester.all
    @users = User.where(admin: false)
  end

  def check_admin
    unless current_user.admin?
      redirect_to semesters_path, alert: "Access denied."
    end
  end
end
