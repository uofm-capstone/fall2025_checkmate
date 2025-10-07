class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]

  load_and_authorize_resource class: Team

  def index
    @teams = Team.all
    @team = Team.new
    render :index
  end

  def show
    @team_members = @team.students
    render :show
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @current_semester = Semester.order(created_at: :desc).first
    @team.semester = @current_semester
    authorize! :create, @team

    if @team.save
      redirect_to teams_path, notice: 'Team was successfully created.'
    else
      @semesters = Semester.all
      @teams = Team.all  # needed if your index lists teams
      render :index
    end
  end

  def edit
    @semesters = Semester.all
    @students = Student.where.not(id: @team.student_ids)
  end
  
  def update
    if @team.update(team_params)
      redirect_to teams_path, notice: 'Team was successfully updated.'
    else
      @current_semester = Semester.order(created_at: :desc).first
      @students = Student.where.not(id: @team.student_ids)
      # Re-render the whole index so the modal + errors appear like "new"
      @teams = Team.all
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to teams_path, notice: 'Team was successfully deleted.'
  end

  def add_member
    authorize! :update, @team
    @student = Student.find(params[:student_id])

    student_team = StudentTeam.new(student: @student, team: @team)

    if student_team.save
      redirect_to edit_team_path(@team), notice: 'Member was successfully added to the team.'
    else
      redirect_to edit_team_path(@team), alert: 'Failed to add member to the team.'
    end
  end

  def remove_member
    authorize! :update, @team
    @student_team = StudentTeam.find_by(student_id: params[:student_id], team_id: @team.id)

    if @student_team&.destroy
      redirect_to edit_team_path(@team), notice: 'Member was successfully removed from the team.'
    else
      redirect_to edit_team_path(@team), alert: 'Failed to remove member from the team.'
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :description, :github_token, :repo_url, :project_board_url, :timesheet_url, :client_notes_url)
  end
end
