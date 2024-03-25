class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_semesters
  
    private
  
    def set_semesters
      @semesters = Semester.all
    end
  end
  