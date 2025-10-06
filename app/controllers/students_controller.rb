# app/controllers/students_controller.rb
class StudentsController < ApplicationController
  skip_before_action :ensure_semester_exists, raise: false rescue nil
  before_action :set_student, only: %i[show edit update destroy]

  def index
    @students = Student.order(:semester).order(Arel.sql('LOWER(full_name)'))
    @student = Student.new
  end

  def show; end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to semester_classlist_path(@student.semester_id), notice: "Student was successfully added."
    else
      @students = Student.order(:semester).order(Arel.sql('LOWER(full_name)'))
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Student updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "Student removed."
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:full_name, :email, :github_username, :team_name, :semester_id)
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to students_path, alert: "Student not found."
  end
end
