class AdminController < ApplicationController
  before_action :check_ta_or_admin
  before_action :check_admin, only: [:destroy]


  def dashboard
    @semesters = Semester.all
    @users = User.all.order(:email)
  end

  def check_admin
    unless current_user.admin?
      # redirect_to semesters_path, alert: "Access denied."
      redirect_to admin_dashboard_path, alert: "This action requires admin privileges."
    end
  end

  def check_ta_or_admin
    unless current_user.ta? || current_user.admin?
      redirect_to semesters_path, alert: "Access denied."
    end
  end

  def check_permissions
    user_to_update = User.find(params[:id])

    # Only admins can change roles
    unless current_user.admin?
      redirect_to admin_dashboard_path, alert: "You don't have permission to change user roles."
      return
    end

    # Cannot change role of another admin
    if user_to_update.admin? && current_user.id != user_to_update.id
      redirect_to admin_dashboard_path, alert: "Cannot modify another admin's role."
      return
    end

    # Cannot set a role higher than your own
    if params[:role].to_i > current_user.role_before_type_cast
      redirect_to admin_dashboard_path, alert: "Cannot assign a role higher than your own."
      return
    end
  end


  def update_role
    @user = User.find(params[:id])

    if @user.update(role: params[:role])
      redirect_to admin_dashboard_path, notice: "#{@user.email}'s role has been updated to #{params[:role].humanize}."
    else
      redirect_to admin_dashboard_path, alert: "Failed to update role."
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "user was successfully deleted"
    redirect_to admin_path, status: :see_other
  end
end
