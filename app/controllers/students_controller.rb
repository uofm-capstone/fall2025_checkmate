# app/controllers/students_controller.rb
class StudentsController < ApplicationController
  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to semester_classlist_path(@student.semester), notice: 'Student was successfully added.'
    else
      render :new
    end
  end

  private

  def student_params
    params.require(:student).permit(:name, :semester_id)
  end
end
