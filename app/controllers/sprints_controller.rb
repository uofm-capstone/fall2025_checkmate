class SprintsController < ApplicationController
  before_action :set_semester
  before_action :set_sprint, only: [:show, :edit, :update, :destroy]
  before_action :check_permission, only: [:new, :create, :edit, :update, :destroy]

  def index
    @semester = Semester.find(params[:semester_id])
    @sprints = @semester.sprints.order(:start_date)
    render :index
  end

  def show
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.find(params[:id])
    render :show
  end

  def new
    @semester = Semester.find(params[:semester_id])
    @sprint = Sprint.new
    render :new
  end

  def edit
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.find(params[:id])
    render :edit
  end

  def create
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.build(params.require(:sprint).permit(:name, :start_date, :end_date))
    if @sprint.save
      flash[:success] = "Sprint saved successfully"
      redirect_to semester_sprints_path(@semester)
    else
      flash.now[:error] = "Sprint could not be saved"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.find(params[:id])
    if @sprint.update(params.require(:sprint).permit(:name, :start_date, :end_date))
      flash[:success] = "Sprint updated successfully"
      redirect_to semester_sprints_path(@semester)
    else
      flash.now[:error] = "Sprint could not be updated"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.find(params[:id])
    @sprint.destroy
    flash[:success] = "Sprint deleted successfully"
    redirect_to semester_sprints_path(@semester)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sprint
    @sprint = Sprint.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sprint_params
    params.require(:sprint).permit(:name, :start_date, :end_date, :user_id)
  end

  def check_permission
    unless current_user.admin?
      redirect_to semesters_path(@semester), alert: "You don't have permission to manage sprints for this semester."
    end
  end
end
