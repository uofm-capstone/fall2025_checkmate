class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]

  # GET /students
  def index
    @students = Student.includes(:team).order('LOWER(full_name)')
    @student  = Student.new
    @teams    = Team.order(:name)
  end

  # GET /students/:id
  def show; end

  # GET /students/new
  def new
    @student = Student.new
    @teams   = Team.order(:name)
  end

  # POST /students
  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to students_path, notice: "Student added."
    else
      @teams = Team.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /students/:id/edit
  def edit
    @teams = Team.order(:name)
  end

  # PATCH/PUT /students/:id
  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "Student updated."
    else
      @teams = Team.order(:name)
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
    params.require(:student).permit(:full_name, :email, :github_username, :team_id)
  end
end
