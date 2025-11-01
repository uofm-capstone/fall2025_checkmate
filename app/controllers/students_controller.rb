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
    @student.semester = Semester.find(session[:last_viewed_semester_id])
    authorize! :create, @student rescue nil
    if @student.save
      semester = @current_semester
      redirect_to students_path, notice: "Student was successfully added."
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
    @current_semester = Semester.find_by(id: session[:last_viewed_semester_id])
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
      Student.where(semester_id: session[:last_viewed_semester_id]).order(Arel.sql("LOWER(full_name)"))
      Student.where(semester_id: session[:last_viewed_semester_id]).order(Arel.sql("LOWER(full_name)"))
  end

  def student_params
    params.require(:student).permit(:name, :full_name, :email, :github_username, :team_id, :team_name)
  end
end
