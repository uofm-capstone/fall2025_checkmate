# In app/controllers/admin_controller.rb
class AdminController < ApplicationController
  before_action :check_ta_or_admin
  before_action :load_user, only: [:update_role, :destroy]
  authorize_resource :user, only: [:update_role, :destroy]

  def dashboard
    @semesters = Semester.all
    @users = User.all.order(:email)
  end

  def check_ta_or_admin
    unless current_user.ta? || current_user.admin?
      redirect_to semesters_path, alert: "Access denied."
    end
  end

  def update_role
    # Check if trying to modify another admin's role
    if @user.admin? && current_user.id != @user.id
      redirect_to admin_dashboard_path, alert: "Cannot modify another admin's role."
      return
    end

    # Check if trying to assign a higher role than current user
    if params[:role].to_i > current_user.role_before_type_cast
      redirect_to admin_dashboard_path, alert: "Cannot assign a role higher than your own."
      return
    end

    if @user.update(role: params[:role])
      redirect_to admin_dashboard_path, notice: "#{@user.email}'s role has been updated to #{params[:role].humanize}."
    else
      redirect_to admin_dashboard_path, alert: "Failed to update role."
    end
  end

  def destroy
    # Additional check to prevent admin from deleting themselves or other admins
    if @user.admin? && current_user.id != @user.id
      redirect_to admin_dashboard_path, alert: "Cannot delete another admin."
      return
    end

    @user.destroy
    flash[:success] = "User was successfully deleted"
    redirect_to admin_path, status: :see_other
  end

  private

  def load_user
    @user = User.find(params[:id])
  end
end
