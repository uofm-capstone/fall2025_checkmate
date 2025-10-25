# app/controllers/semesters_controller.rb
class SemestersController < ApplicationController
  require 'text'
  helper_method :get_client_score
  helper_method :team_exist
  helper_method :get_flags
  helper_method :unfinished_sprint

  include PreprocessorHelper
  include TeamsHelper
  include SprintsHelper
  include ClientScoreHelper
  include ClientDisplayHelper
  include ClientSurveyPatternsHelper

  before_action :set_semester, only: [:show, :edit, :update, :destroy]
  before_action :check_ownership, only: [:destroy]
  before_action :check_admin

  # --------------------------------------------------------
  # SETUP & AUTHORIZATION HELPERS
  # --------------------------------------------------------

  # Finds the semester record by ID before certain actions.
  def set_semester
    @semester = Semester.find(params[:id])
  end

  # Restricts deletion to the semester's creator or an admin.
  def check_ownership
    unless current_user == @semester.user || current_user.admin?
      redirect_to(semesters_path, alert: "You are not authorized to perform this action.")
    end
  end

  # Restricts accessing semesters to admin users.
  def check_admin
    unless current_user.admin?
      redirect_to root_path(flash[:alert] = "You are not authorized to access this page.")
    end
  end

  # --------------------------------------------------------
  # INDEX / HOME
  # --------------------------------------------------------

  # Displays all semesters on the main Semesters page.
  def home
    @semesters = Semester.order(:year)
    render :home
  end

  # --------------------------------------------------------
  # SHOW PAGE
  # --------------------------------------------------------

  # Displays semester details, including teams and sprint data.
  def show
    session[:return_to] ||= request.referer
    @semester = Semester.find(params[:id])

    # Store the current semester in the session.
    session[:last_viewed_semester_id] = @semester.id

    # Load all teams and sprint info.
    @teams = @semester.teams
    @sprint_list = @semester.sprints.pluck(:name)
    @flags = {}

    # Build flags data per sprint and team for status display.
    @sprint_list.each do |sprint|
      @flags[sprint] = {}
      @teams.each do |team|
        @flags[sprint][team.name] = get_flags(@semester, sprint, team.name)
      end
    end

    # Load repository and sprint info for display.
    @repos = current_user.repositories
    @sprints = @semester.sprints
    @start_dates, @end_dates, @team_names, @repo_owners, @repo_names, @access_tokens, @sprint_numbers = get_git_info(@semester)

    render :show
  end

  # --------------------------------------------------------
  # NEW / CREATE SEMESTER
  # --------------------------------------------------------

  # Renders the "New Semester" form.
  def new
    @semester = Semester.new

    # Prefill semester/year from params if coming from redirect.
    @semester.semester = params[:semester] if params[:semester]
    @semester.year = params[:year] if params[:year]
    render :new
  end

  # Handles form submission for creating a new semester.
  # Automatically imports students and teams from uploaded CSV.
  def create
    @semester = current_user.semester.build(semester: params[:semester], year: params[:year])

    # Attach uploaded CSV files if present.
    @semester.student_csv.attach(params[:student_csv]) if params[:student_csv].present?
    @semester.client_csv.attach(params[:client_csv])   if params[:client_csv].present?
    @semester.git_csv.attach(params[:git_csv])         if params[:git_csv].present?

    if @semester.save
      # Import Student CSV (creates students + teams).
      if @semester.student_csv.attached?
        unless @semester.import_students_from_csv
          flash.now[:alert] = @semester.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity and return
        end
      end

      redirect_to @semester, notice: "Semester created successfully and students imported."
    else
      flash.now[:error] = "Semester creation failed."
      render :new, status: :unprocessable_entity
    end
  end

  # --------------------------------------------------------
  # EDIT / UPDATE SEMESTER
  # --------------------------------------------------------

  # Renders the "Edit Semester" form.
  def edit
    session[:return_to] ||= request.referer
    @semester = Semester.find(params[:id])
    render :edit
  end

  # Updates semester info (semester, year, and CSV uploads).
  # Re-imports student CSV if a new one is uploaded.
  def update
    @semester = Semester.find(params[:id])
    was_student_csv_attached = @semester.student_csv.attached?

    if @semester.update(params.require(:semester).permit(:semester, :year, :student_csv, :client_csv, :git_csv))
      # Import new CSV if just uploaded.
      if !was_student_csv_attached && @semester.student_csv.attached?
        unless @semester.import_students_from_csv
          flash.now[:alert] = @semester.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity and return
        end
      end

      flash[:success] = "Semester was successfully updated!"
      redirect_to semester_url(@semester)
    else
      flash.now[:error] = "Semester update failed!"
      render :edit, status: :unprocessable_entity
    end
  end

  # --------------------------------------------------------
  # DESTROY SEMESTER
  # --------------------------------------------------------

  # Deletes the selected semester record.
  def destroy
    @semester = Semester.find(params[:id])
    @semester.destroy
    flash[:success] = "Semester was successfully deleted"
    redirect_to semesters_path, status: :see_other
  end

  # --------------------------------------------------------
  # STATUS PAGE
  # --------------------------------------------------------

  # Displays semester progress status for all teams/sprints.
  def status
    @semester = Semester.find_by(id: params[:id])
    return redirect_to(semesters_path) unless @semester
    
    session[:last_viewed_semester_id] = @semester.id

    @teams = @semester.teams
    @sprint_list = @semester.sprints.pluck(:name)
    @flags = {}

    @sprint_list.each do |sprint|
      @flags[sprint] = {}
      @teams.each do |team|
        @flags[sprint][team.name] = get_flags(@semester, sprint, team.name)
      end
    end

    @repos = current_user.repositories
    @sprints = @semester.sprints
    @start_dates, @end_dates, @team_names, @repo_owners, @repo_names, @access_tokens, @sprint_numbers = get_git_info(@semester)

    render :show
  end

  # --------------------------------------------------------
  # UPLOAD ADDITIONAL CSV FILES
  # --------------------------------------------------------

  # Handles Sprint CSV uploads (student/client data per sprint).
  def upload_sprint_csv
    @semester = Semester.find(params[:id])
    sprint_name = params[:sprint_name]

    @semester.student_csv.attach(params[:student_csv]) if params[:student_csv].present?
    @semester.client_csv.attach(params[:client_csv]) if params[:client_csv].present?

    flash[:notice] = "#{sprint_name} CSVs uploaded!"
    redirect_to semester_path(@semester)
  end

  # --------------------------------------------------------
  # HELPER / UTILITY METHODS
  # --------------------------------------------------------

  # Returns a list of all team names for a given semester.
  def getTeams(semester)
    semester.teams.pluck(:name)
  end

  # Builds flag indicators for teams on the status page.
  def get_flags(semester, sprint, team)
    flags = []
    begin
      semester.student_csv.open do |tempStudent|
        studentData = SmarterCSV.process(tempStudent.path)
        student_survey = studentData.find_all { |survey| survey[:q2] == team && survey[:q22] == sprint }
        flags.append("student blank") if student_survey.blank?
      end
    rescue => e
      flags.append("no data")
    end
    flags
  end

  # Checks if any teams exist (used in views).
  def team_exist(arr)
    arr.length > 0
  end

  # Loads static student classlist CSV for older semesters (legacy feature).
  def classlist
    @semester = Semester.find(params[:id])
    filepath = Rails.root.join('lib', 'assets', 'Students_list.csv')
    @students_info = []

    CSV.foreach(filepath, headers: true) do |row|
      @students_info << { full_name: row['Name'], role: row['Role'] }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to semesters_path, alert: 'Semester not found.'
  end

  # Determines if all teams for a sprint are marked "student blank".
  def unfinished_sprint(teams, flags, sprint)
    teams.each do |t|
      return false if flags[sprint][t] != ["student blank"]
    end
    true
  end

  # --------------------------------------------------------
  # PRIVATE METHODS
  # --------------------------------------------------------

  private

  # Permits only the allowed semester params for strong parameter safety.
  def semester_params
    params.permit(
      :semester, :year, :sprint_number,
      sprints_attributes: [:id, :_destroy, :start_date, :end_date],
      student_csv: [], client_csv: [], git_csv: []
    )
  end
end
