class SprintsController < ApplicationController
  before_action :set_sprint, only: [:show, :edit, :update, :destroy]

  def index
    @semester = Semester.find(params[:semester_id])
    @sprints = @semester.sprints
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
      redirect_to semester_sprints_url(@semester)
    else
      flash.now[:error] = "Sprint could not be saved"
      render :new
    end
  end

  def update
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.find(params[:id])
    if @sprint.update(params.require(:sprint).permit(:name, :start_date, :end_date))
      flash[:success] = "Sprint updated successfully"
      redirect_to semester_sprint_url(@semester, @sprint)
    else
      flash.now[:error] = "Sprint could not be updated"
      render :new
    end
  end

  def destroy
    @semester = Semester.find(params[:semester_id])
    @sprint = @semester.sprints.find(params[:id])
    @sprint.destroy
    flash[:success] = "Sprint deleted successfully"
    redirect_to semester_sprints_url(@semester)
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
end
