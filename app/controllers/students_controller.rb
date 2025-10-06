class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource class: Student

  # GET /students
  def index
    @students = Student.order(Arel.sql('LOWER(full_name)'))
    @student  = Student.new
    render :index
  end

  # GET /students/:id
  def show
    # If you track memberships via join table, expose them (optional)
    @teams = @student.respond_to?(:teams) ? @student.teams : []
    render :show
  end

  # GET /students/new  (not used if you create via modal on index, but kept for parity)
  def new
    @student = Student.new
    @teams = Team.all if defined?(Team)
  end

  # POST /students
  def create
    @student = Student.new(student_params)
    authorize! :create, @student

    if @student.save
      redirect_to students_path, notice: 'Student was successfully created.'
    else
      @students = Student.order(Arel.sql('LOWER(full_name)'))
      @teams = Team.all if defined?(Team)
      render :index
    end
  end

  # GET /students/:id/edit
  def edit
    @teams = Team.all if defined?(Team)
  end

  # PATCH/PUT /students/:id
  def update
    if @student.update(student_params)
      redirect_to students_path, notice: 'Student was successfully updated.'
    else
      @teams = Team.all if defined?(Team)
      render :edit
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
  end

  def student_params
    params.require(:student).permit(:full_name, :email, :github_username, :team_name, :team_id)
  end
end
