class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]

  load_and_authorize_resource class: Team


  def index
    @teams = Team.all
    render :index
  end

  def show
    @team_members = @team.users
    @repositories = @team.repositories
    render :show
  end

  def new
    @team = Team.new
    @semesters = Semester.all
  end

  def create
    @team = Team.new(team_params)
    authorize! :create, @team

    if @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      @semesters = Semester.all
      render :new
    end
  end

  def edit
    @semesters = Semester.all
    @users = User.where.not(id: @team.user_ids)
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'Team was successfully updated.'
    else
      @semesters = Semester.all
      @users = User.where.not(id: @team.user_ids)
      render :edit
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to teams_path, notice: 'Team was successfully deleted.'
  end

  def add_member
    authorize! :update, @team
    @user = User.find(params[:user_id])

    user_team = UserTeam.new(user: @user, team: @team)

    if user_team.save
      redirect_to edit_team_path(@team), notice: 'Member was successfully added to the team.'
    else
      redirect_to edit_team_path(@team), alert: 'Failed to add member to the team.'
    end
  end

  def remove_member
    authorize! :update, @team
    @user_team = UserTeam.find_by(user_id: params[:user_id], team_id: @team.id)

    if @user_team&.destroy
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
    params.require(:team).permit(:name, :description, :semester_id, :github_token)
  end
end
