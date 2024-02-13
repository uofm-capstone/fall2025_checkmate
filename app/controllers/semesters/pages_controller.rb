class PagesController < ApplicationController
  require 'text'

  def github_key
    @semester = Semester.find(params[:semester_id])
    #render pages/github_key.html.erb
  end

  #Users go to this page to manually paste in their GitHub API key.
  #A good quick feature update would be to allow users to authenticate to GitHub in-app
  #And let the app handle the API key in the background
  #Also, this poses unavoidable security risks, so be careful
  def post_github_key
    begin 
      current_user.github_token = "#{params[:api_key]}"
      current_user.save!
      redirect_to semesters_url, notice: 'Your GitHub API key has been successfully updated.'
    rescue
      flash.now[:alert] = 'Error! Unable to update GitHub API Key'
      render :github_key
    end
  end

end


