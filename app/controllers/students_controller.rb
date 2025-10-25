class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource class: Student rescue nil
  before_action :set_current_semester
  before_action :load_teams, only: [:index, :new, :edit, :create, :update]

  def index
    @student  = Student.new
    @students = load_students_for_index
    render :index
  end

  def show
    render :show
  end

  def new
    @student = Student.new
    render :new
  end

  def create
    @student = Student.new(student_params)
    authorize! :create, @student rescue nil
    if @student.save
      semester = @student&.team&.semester || @current_semester
      if semester
        redirect_to semester_classlist_path(semester), notice: "Student was successfully added."
      else
        redirect_to students_path, notice: "Student was successfully added."
      end
    else
      @students = load_students_for_index
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    authorize! :update, @student rescue nil
    render :edit
  end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Student was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student was successfully deleted."
  end

  private

  def set_student
    @student = Student.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to students_path, alert: "Student not found."
  end

  def set_current_semester
    @current_semester = Semester.order(created_at: :desc).first
  end

  def load_teams
    @teams =
      if @current_semester
        Team.where(semester_id: @current_semester.id).order(:name)
      else
        Team.order(:name)
      end
  end

  def load_students_for_index
    if @current_semester && Student.reflect_on_association(:team)
      Student.includes(team: :semester)
             .where(teams: { semester_id: @current_semester.id })
             .order(Arel.sql("LOWER(full_name)"))
    else
      Student.order(Arel.sql("LOWER(full_name)"))
    end
  end

  def student_params
    params.require(:student).permit(:name, :full_name, :email, :github_username, :team_id, :team_name)
  end
end
