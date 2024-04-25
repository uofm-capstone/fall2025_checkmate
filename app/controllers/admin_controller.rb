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

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "user was successfully deleted"
    redirect_to admin_path, status: :see_other
  end

end
