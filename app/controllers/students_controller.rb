class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource class: Student rescue nil

  # GET /students
  def index
    @students = Student.all.order(:full_name)
    @student = Student.new
    @teams = Team.all
    render :index
  end

  def show
  render :show
  end

  def new
    @student = Student.new
    @teams = Team.all
  end

  def create
    @student = Student.new(student_params)
    @current_semester = Semester.order(created_at: :desc).first
    authorize! :create, @student rescue nil
    if @student.save
      semester = @student.try(:team).try(:semester) || @current_semester
      if semester
        redirect_to semester_classlist_path(semester), notice: 'Student was successfully added.'
      else
        redirect_to students_path, notice: 'Student was successfully added.'
      end
    else
      @students =if @current_semester && Student.reflect_on_association(:team)
          Student.includes(team: :semester).where(teams: { semester_id: @current_semester.id }).order(Arel.sql('LOWER(full_name)'))
        else
          Student.order(Arel.sql('LOWER(full_name)'))
        end
      @teams = if @current_semester
          Team.where(semester_id: @current_semester.id).order(:name)
        else
          Team.order(:name)
        end
      render :index
    end
  end

  def edit
    @teams = Team.all
  end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: 'Student was successfully updated.'
    else
      @current_semester = Semester.order(created_at: :desc).first
      @teams = @current_semester ? Team.where(semester: @current_semester).order(:name) : Team.order(:name)
      render :edit
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: 'Student was successfully deleted.'
  end

  private

  def set_student
    @student = Student.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to students_path, alert: 'Student not found.'
  end

  def student_params
    params.require(:student).permit(:full_name, :email, :github_username, :team_id, :team_name)
  end
end
