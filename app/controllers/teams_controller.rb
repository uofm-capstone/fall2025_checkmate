class TeamsController < ApplicationController
  before_action :set_team, only: [:edit, :update, :destroy]

  def index
    @teams = Team.includes(:members)
  end

  def new
    @team = Team.new
    @team.members.build
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to teams_index_path, notice: "Team created successfully."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @team.update(team_params)
      redirect_to teams_index_path, notice: "Team updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_index_path, notice: "Team deleted."
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :sponsor_name, :github_repo, :project_board, :access_token,
      members_attributes: [:id, :name, :github_username, :_destroy])
  end
end