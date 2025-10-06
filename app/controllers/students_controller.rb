# app/controllers/students_controller.rb
class StudentsController < ApplicationController
  skip_before_action :ensure_semester_exists, raise: false rescue nil

  before_action :set_student, only: %i[show edit update destroy]

  # GET /students
  def index
    @students = Student.order(Arel.sql('LOWER(full_name)'))
  end

  # GET /students/:id
  def show; end

  # GET /students/new
  def new
    @student = Student.new
    @teams = Team.order(:name)
  end

  # POST /students
  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to semester_classlist_path(@student.semester), notice: 'Student was successfully added.'
    else
      render :new
    end
  end

  # GET /students/:id/edit
  def edit; end

  # PATCH/PUT /students/:id
  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Student updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /students/:id
  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student removed."
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:full_name, :email, :github_username, :team_name)
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to students_path, alert: "Student not found."
  end
end

  private

  def student_params
    params.require(:student).permit(:name, :semester_id)
  end
end
