# broke survey page
class SemestersController < ApplicationController
  require 'text'
  helper_method :get_client_score
  helper_method :team_exist
  helper_method :get_flags
  helper_method :unfinished_sprint



  include PreprocessorHelper
  include TeamsHelper
  include SprintsHelper
  include ClientScoreHelper
  include ClientDisplayHelper
  include ClientSurveyPatternsHelper

  before_action :set_semester, only: [:show, :edit, :update, :destroy]
  before_action :check_ownership, only: [:destroy]
  before_action :check_admin, only: [:new, :create]


  def set_semester
      @semester = Semester.find(params[:id])
  end

  def check_ownership
      unless current_user == @semester.user || current_user.admin?
        redirect_to(semesters_path, alert: "You are not authorized to perform this action.")
      end
  end

  def check_admin
      unless current_user.admin?
          redirect_to root_path(alert_message: "You are not authorized to perform this action.")
      end
  end

  def home
      @semesters = Semester.order(:year)
      render :home
  end

  def show
      session[:return_to] ||= request.referer
      @semester = Semester.find(params[:id])
      @teams = getTeams(@semester)
      # TODO: allow user to select how many Sprints there are
      @sprint_list = ["Sprint 1", "Sprint 2", "Sprint 3", "Sprint 4"]
      @flags = {}
      @sprint_list.each do |sprint|
          @flags[sprint] = {}
          @teams.each do |team|
              @flags[sprint][team] = get_flags(@semester, sprint, team)
          end
      end
      @repos = current_user.repositories
    #   @repo = Repository.find(2)
      @sprints = @semester.sprints
      @start_dates, @end_dates, @team_names, @repo_owners, @repo_names, @access_tokens, @sprint_numbers = get_git_info(@semester)

      render :show
  end

  def new
      @semester = Semester.new
      # @semester.sprints.build
      # render :new
  end

  def create
      @semester = current_user.semester.build(semester_params)

      if params[:student_csv].present?
          @semester.student_csv.attach(params[:student_csv])
      end

      if params[:client_csv].present?
          @semester.client_csv.attach(params[:client_csv])
      end

      if params[:git_csv].present?
          @semester.git_csv.attach(params[:git_csv])
      end

      if @semester.save
          redirect_to @semester, notice: 'Semester was successfully created.'
      else
          render :new
      end
  end



  def edit
      session[:return_to] ||= request.referer
      @semester = Semester.find(params[:id])
      render :edit
  end

  def update
      @semester = Semester.find(params[:id])
      if @semester.update(params.require(:semester).permit(:semester, :year, :student_csv, :client_csv, :git_csv))
          flash[:success] = "Semester was successfully updated!"
          redirect_to semester_url(@semester)
      else
          flash.now[:error] = "Semester update failed!"
          render :edit
      end
  end

    def destroy
        @semester = Semester.find(params[:id])
        @semester.destroy
        flash[:success] = "Semester was successfully deleted"
        redirect_to semesters_path, status: :see_other
    end
    def destroy
        @semester = Semester.find(params[:id])
        @semester.destroy
        flash[:success] = "Semester was successfully deleted"
        redirect_to semesters_path, status: :see_other
    end

    def status
        @semester = Semester.find(params[:id])
        @teams = getTeams(@semester)
        @sprint_list = ["Sprint 1", "Sprint 2", "Sprint 3", "Sprint 4"]
        @flags = {}

        @sprint_list.each do |sprint|
            @flags[sprint] = {}
            @teams.each do |team|
                @flags[sprint][team] = get_flags(@semester, sprint, team)
            end
        end

        render :status
    end

    def upload_sprint_csv
        @semester = Semester.find(params[:id])
        sprint_name = params[:sprint_name]

        @semester.student_csv.attach(params[:student_csv]) if params[:student_csv].present?
        @semester.client_csv.attach(params[:client_csv]) if params[:client_csv].present?

        flash[:notice] = "#{sprint_name} CSVs uploaded!"
        redirect_to semester_path(@semester)
    end



  def getTeams(semester)
      @teams = []
      begin
          # Downloads and temporarily store the student_csv file
          semester.student_csv.open do |tempfile|
              begin
                  @studentData = SmarterCSV.process(tempfile.path)
  def getTeams(semester)
      @teams = []
      begin
          # Downloads and temporarily store the student_csv file
          semester.student_csv.open do |tempfile|
              begin
                  @studentData = SmarterCSV.process(tempfile.path)

                  # Delete the 2 header columns before the data
                  @studentData.delete_at(0)
                  @studentData.delete_at(0)

                  @studentData.each do |row|
                      if @teams.exclude? row[:q2]
                          @teams.append(row[:q2])
                      end
                  end
                  @teams.uniq()
              rescue => exception
                  flash.now[:alert] = "Error! Unable to read data. Please update your student data file"
              end
          end
      rescue => exception
          flash.now[:alert] = "This semester does not have a student survey"
      end
      session[:teams_list] = @teams
      return @teams
  end





  def team
      @semester = Semester.find(params[:semester_id])

      @teams = getTeams(@semester)
      @teams ||= []
      @team =  params[:team]
      @repositories = Repository.where(team: @team)
      # Find the specific repository for the current team
      @repo = @repositories.find { |repo| repo.team == @team } if @team.present?


      # TODO: Allow user to select how many Sprint's there are
      @sprints = ["Sprint 1", "Sprint 2", "Sprint 3", "Sprint 4"]
      # @sprint = params[:sprint]
      @sprint = params[:sprint] || @sprints.first

      @not_empty_questions = [] # check if questions are empty (without any responses)

      # stores all the flags for the team
      @flags = []

      # Processes the student data first
      begin
          # Downloads and temporarily store the student_csv file
          @semester.student_csv.open do |tempStudent|
              begin
                  @studentData = SmarterCSV.process(tempStudent.path)

                  @student_survey = @studentData.find_all{|survey| survey[:q2]==@team && survey[:q22]==@sprint}
                  @question_titles = @studentData[0]

                  if @student_survey.blank?
                      @flags.append("student blank")
                      puts "student blank"
                  end

                  @self_submitted_names = []
                  if @student_survey.any?
                      @self_submitted_names.push([@student_survey[0][:q1]], [@student_survey[0][:q10]])
                      additional_keys = [:q13_2_text, :q23_2_text, :q24_2_text]
                      additional_keys.each do |key|
                          @self_submitted_names.push([@student_survey[0][key]]) if @student_survey[0][key]
                      end
                  end

                  if @self_submitted_names then @self_submitted_names.each do |name|
                      white = Text::WhiteSimilarity.new
                      name.push([])
                      name.push([])
                      name.push([])
                      name.push([])

                      @student_survey.each do |survey|
                          max = white.similarity(name[0], survey[:q1])
                          name_to_add = ["#{survey[:q1]}'s survey","q1",survey[:q1]]
                          self_scores = [survey[:q11_1],survey[:q11_2],survey[:q11_3],survey[:q11_4],survey[:q11_5],survey[:q11_6]]
                          Rails.logger.debug("NAMEE ADD")
                          Rails.logger.debug("#{self_scores}")
                          scores = nil
                          if white.similarity(name[0], survey[:q10]) > max
                              max = white.similarity(name[0], survey[:q10])
                              name_to_add = ["#{survey[:q1]}'s survey","q10",survey[:q10]]
                              scores = [survey[:q21_1],survey[:q21_2],survey[:q21_3],survey[:q21_4],survey[:q21_5],survey[:q21_6]]
                              self_scores = nil
                          end
                          if survey[:q13_2_text] && white.similarity(name[0], survey[:q13_2_text]) > max
                              max = white.similarity(name[0], survey[:q13_2_text])
                              name_to_add = ["#{survey[:q1]}'s survey","q13_2_text",survey[:q13_2_text]]
                              scores = [survey[:q15_1],survey[:q15_2],survey[:q15_3],survey[:q15_4],survey[:q15_5],survey[:q15_6]]
                              self_scores = nil
                          end
                          if survey[:q23_2_text] && white.similarity(name[0], survey[:q23_2_text]) > max
                              max = white.similarity(name[0], survey[:q23_2_text])
                              name_to_add = ["#{survey[:q1]}'s survey","q23_2_text",survey[:q23_2_text]]
                              scores = [survey[:q16_1],survey[:q16_2],survey[:q16_3],survey[:q16_4],survey[:q16_5],survey[:q16_6]]
                              self_scores = nil
                          end
                          if survey[:q24_2_text] && white.similarity(name[0], survey[:q24_2_text]) > max
                              max = white.similarity(name[0], survey[:q24_2_text])
                              name_to_add = ["#{survey[:q1]}'s survey","q24_2_text",survey[:q24_2_text]]
                              scores = [survey[:q25_1],survey[:q25_2],survey[:q25_3],survey[:q25_4],survey[:q25_5],survey[:q25_6]]
                              self_scores = nil
                          end

                          scores&.map! do |score|
                              case score
                              when 'Always' then 5
                              when 'Most of the time' then 4
                              when 'About half the time' then 3
                              when 'Sometimes' then 2
                              when 'Never' then 1
                              else 0
                              end
                            end

                            self_scores&.map! do |score|
                              case score
                              when 'Always' then 5
                              when 'Most of the time' then 4
                              when 'About half the time' then 3
                              when 'Sometimes' then 2
                              when 'Never' then 1
                              else 0
                              end
                            end
                          if self_scores
                              name[1] = name[1] + self_scores
                          end
                          if scores
                              name[2] = name[2] + scores
                          end
                          name.push(name_to_add)
                      end

                      self_scores = name[1].compact

                      # Remove any nil elements from self_scores and peer_scores arrays to ensure accurate calculations
                      name[1].compact!
                      name[2].compact!

                      # combine both name[1] + name[2]
                      including_self_scores = name[1] + name[2]

                      # Check if there are any scores present (self or peer) to calculate the average including self
                      if including_self_scores.present?
                          name.push((including_self_scores.sum / including_self_scores.size.to_f).round(1))
                      elsif name[2].present?
                          name.push((name[2].sum / name[2].size.to_f).round(1))
                      else
                          name.push("*Did not submit survey*")
                      end

                      name.push((name[2].sum / name[2].size.to_f).round(1))

                  #     Rails.logger.debug("DEBUGGGGGG #{name[-2]}")
                  #    Rails.logger.debug("NAMEE ADD")
                  #   Rails.logger.debug("#{self_scores}")


                    # stores the flags for the team
                      if name[-2].is_a?(String) && !@flags.include?("missing submit")
                          @flags.append("missing submit")
                      end
                      if name[-2] < 4 && !@flags.include?("low score")
                          @flags.append("low score")
                      end
                      if name.last < 4 && !@flags.include?("low score")
                          @flags.append("low score")
                      end
                  end
              end
              rescue => exception
                  # TODO: This displays when there's data displaying on the survey page for a sprint that does that data
                  # flash.now[:alert] = "Unable to process file"
              end

              # check if students' questions are empty (without any responses)
              question_keys = {
                              q4: 1, q5: 2, q6: 3, q7: 4, q8: 5, q18: 6, q19: 7, q20: 8
                              }
              @student_survey.each do |survey|
                  question_keys.each do |key, value|
                      @not_empty_questions.append(value) unless survey[key].nil?
                  end
              end
          end
      rescue => exception
          flash.now[:alert] = "This semester does not have any student survey"
          @flags.append("student blank")
      end

      client_data, flags = process_client_data(@semester, @team, @sprint)

      @full_questions = client_data[:full_questions]
      @cliSurvey = client_data[:cliSurvey]
      @flags = flags
      @start_dates, @end_dates, @team_names, @repo_owners, @repo_names, @access_tokens, @sprint_numbers = get_git_info(@semester)
  # set_team_flags

      render :team
  end




  def get_flags(semester, sprint, team)
      # stores all the flags for the team
      flags = []

      # Processes the student data first
      begin
          # Downloads and temporarily store the student_csv file
          semester.student_csv.open do |tempStudent|
              begin
                  studentData = SmarterCSV.process(tempStudent.path)

                  student_survey = studentData.find_all{|survey| survey[:q2]==team && survey[:q22]==sprint}
                  question_titles = studentData[0]

                  if student_survey.blank?
                      flags.append("student blank")
                  end

                  # Check for client feedback
                  begin
                      semester.client_csv.open do |tempClient|
                          clientData = SmarterCSV.process(tempClient.path)
                          client_survey = clientData.find_all { |survey| 
                              survey[:q1_team] == team && survey[:q3] == sprint 
                          }
                          
                          if client_survey.blank?
                              flags.append("no client score")
                          else
                              # Check if all required client feedback questions are answered
                              required_questions = ['q2_1', 'q2_2', 'q2_3', 'q2_4', 'q2_5', 'q2_6']
                              missing_questions = required_questions.reject { |q| client_survey[0].has_key?(q.to_sym) }
                              
                              if missing_questions.any?
                                  flags.append("incomplete client feedback")
                              else
                                  # Check if any responses are below expectations
                                  low_scores = client_survey[0].select { |k, v| 
                                      k.to_s.start_with?('q2_') && 
                                      v.present? && 
                                      !['exceeded expectations', 'met expectations'].include?(v.strip.downcase)
                                  }
                                  
                                  if low_scores.any?
                                      flags.append("low client score")
                                  end
                              end
                          end
                      end
                  rescue => e
                      flags.append("no client score")
                  end

                  if student_survey[0] then self_submitted_names = [[student_survey[0][:q1]],[student_survey[0][:q10]]] end
                  if student_survey[0] and student_survey[0][:q13_2_text] then self_submitted_names.push([student_survey[0][:q13_2_text]]) end
                  if student_survey[0] and student_survey[0][:q23_2_text] then self_submitted_names.push([student_survey[0][:q23_2_text]]) end
                  if student_survey[0] and student_survey[0][:q24_2_text] then self_submitted_names.push([student_survey[0][:q24_2_text]]) end

                  if self_submitted_names then self_submitted_names.each do |name|
                      white = Text::WhiteSimilarity.new
                      name.push([])
                      name.push([])
                      name.push([])
                      name.push([])

                      student_survey.each do |survey|
                          max = white.similarity(name[0], survey[:q1])
                          name_to_add = ["#{survey[:q1]}'s survey","q1",survey[:q1]]
                          self_scores = [survey[:q11_1],survey[:q11_2],survey[:q11_3],survey[:q11_4],survey[:q11_5],survey[:q11_6]]
                          scores = nil
                          if white.similarity(name[0], survey[:q10]) > max
                              max = white.similarity(name[0], survey[:q10])
                              name_to_add = ["#{survey[:q1]}'s survey","q10",survey[:q10]]
                              scores = [survey[:q21_1],survey[:q21_2],survey[:q21_3],survey[:q21_4],survey[:q21_5],survey[:q21_6]]
                              self_scores = nil
                          end
                          if survey[:q13_2_text] && white.similarity(name[0], survey[:q13_2_text]) > max
                              max = white.similarity(name[0], survey[:q13_2_text])
                              name_to_add = ["#{survey[:q1]}'s survey","q13_2_text",survey[:q13_2_text]]
                              scores = [survey[:q15_1],survey[:q15_2],survey[:q15_3],survey[:q15_4],survey[:q15_5],survey[:q15_6]]
                              self_scores = nil
                          end
                          if survey[:q23_2_text] && white.similarity(name[0], survey[:q23_2_text]) > max
                              max = white.similarity(name[0], survey[:q23_2_text])
                              name_to_add = ["#{survey[:q1]}'s survey","q23_2_text",survey[:q23_2_text]]
                              scores = [survey[:q16_1],survey[:q16_2],survey[:q16_3],survey[:q16_4],survey[:q16_5],survey[:q16_6]]
                              self_scores = nil
                          end
                          if survey[:q24_2_text] && white.similarity(name[0], survey[:q24_2_text]) > max
                              max = white.similarity(name[0], survey[:q24_2_text])
                              name_to_add = ["#{survey[:q1]}'s survey","q24_2_text",survey[:q24_2_text]]
                              scores = [survey[:q25_1],survey[:q25_2],survey[:q25_3],survey[:q25_4],survey[:q25_5],survey[:q25_6]]
                              self_scores = nil
                          end

                          if scores
                              scores.map!{ |score|
                                  if score=="Always"
                                      5
                                  elsif score=="Most of the time"
                                      4
                                  elsif score=="About half the time"
                                      3
                                  elsif score=="Sometimes"
                                      2
                                  elsif score=="Never"
                                      1
                                  else
                                      score
                                  end
                              }
                          end
                          if self_scores
                              self_scores.map!{ |score|
                                  if score=="Always"
                                      5
                                  elsif score=="Most of the time"
                                      4
                                  elsif score=="About half the time"
                                      3
                                  elsif score=="Sometimes"
                                      2
                                  elsif score=="Never"
                                      1
                                  else
                                      score
                                  end
                              }
                          end
                          if self_scores
                              name[1] = name[1] + self_scores
                          end
                          if scores
                              name[2] = name[2] + scores
                          end
                          name.push(name_to_add)
                      end
                      name[1].compact!
                      name[2].compact!
                      including_self_scores = name[1] + name[2]
                      unless name[1].blank?
                          name.push((including_self_scores.sum / including_self_scores.size.to_f).round(1))
                      else
                          name.push("*Did not submit survey*")
                      end
                      name.push((name[2].sum / name[2].size.to_f).round(1))

                      # stores the flags for the team
                      if name[-2].is_a?(String) && !flags.include?("missing submit")
                          flags.append("missing submit")
                      end
                      if name[-2] < 4 && !flags.include?("-low score")
                          flags.append("low score")
                      end
                      if name.last < 4 && !flags.include?("low score")
                          flags.append("low score")
                      end

                      cscore = get_client_score(semester, team, sprint)
                      if cscore == "No Score"
                          flags.append("no client score")
                      end
                      if cscore <2
                          flags.append("low client score")
                      end
                  end end
              rescue => exception
              end
          end
      rescue => exception
      end
      return flags
  end

  # Use to test if there are any teams that exist
  def team_exist(arr)
      if arr.length() > 0
          return true
      end
      return false
  end

  require 'csv'



  def classlist
      @semester = Semester.find(params[:id])
      filepath = Rails.root.join('lib', 'assets', 'Students_list.csv')
      @students_info = []

      CSV.foreach(filepath, headers: true) do |row|
        @students_info << {name: row['﻿Name'], role: row['Role']}
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to semesters_path, alert: 'Semester not found.'
    end
    # Any other actions should be defined here...

    # This method seems to be a utility method. If it's used in views or needs to be public, it's fine here.
    # If it's only used within the controller, consider moving it inside the private section.
    def unfinished_sprint(teams, flags, sprint)
      teams.each do |t|
        return false if flags[sprint][t] != ["student blank"]
      end
      true
    end

    private

      # Ensure all private methods are within this section.
      def semester_params
        params.permit(
          :semester, :year, :sprint_number, sprints_attributes: [
            :id, :_destroy, :start_date, :end_date
          ],
          student_csv: [], client_csv: [], git_csv: []
        )
      end
      # Ensure all private methods are within this section.
      def semester_params
        params.permit(
          :semester, :year, :sprint_number, sprints_attributes: [
            :id, :_destroy, :start_date, :end_date
          ],
          student_csv: [], client_csv: [], git_csv: []
        )
      end

    end# Any other private utility methods should be defined below this point.

end
