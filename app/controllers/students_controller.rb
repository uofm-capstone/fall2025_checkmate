class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource class: Student rescue nil

  # GET /students
  def index
    @students = Student.all.order(:full_name)
    @student = Student.new
    @teams = Team.all
  end

  # GET /students/:id
  def show; end

  # GET /students/new
  def new
    @student = Student.new
    @teams = Team.all
  end

  # POST /students
  def create
    @student = Student.new(student_params)
    if @student.save
      if @student.respond_to?(:semester) && @student.semester.present?
        redirect_to semester_classlist_path(@student.semester), notice: 'Student was successfully added.'
      else
        redirect_to students_path, notice: 'Student was successfully added.'
      end
    else
      @teams = Team.all
      render :new, status: :unprocessable_entity
    end
  end

  # GET /students/:id/edit
  def edit
    @teams = Team.all
  end

  # PATCH/PUT /students/:id
  def update
    if @student.update(student_params)
      redirect_to students_path, notice: 'Student was successfully updated.'
    else
      @teams = Team.all
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /students/:id
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
    params.require(:student).permit(:name, :full_name, :email, :github_username, :team_id, :semester_id)
  end
end
