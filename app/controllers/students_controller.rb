class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  # GET /students
  def index
    @students = Student.order(Arel.sql('LOWER(full_name)'))
  end

  # GET /students/:id
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # POST /students
  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to students_path, notice: "Student added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /students/:id/edit
  def edit
  end

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

  # Strong params — using team_name (string) to match your views
  def student_params
    params.require(:student).permit(:full_name, :email, :github_username, :team_name)
  end

  # Nice-to-have: handle bad IDs gracefully
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to students_path, alert: "Student not found."
  end
end
