class CommitsController < ApplicationController
  def index
    @repos      = ["uofm-capstone/fall2025_checkmate"]   # your repos
    @users      = ["Dante1d", "zacherynolan", "JacobHensley", "Derron0325"]               # GitHub usernames
    @start_date = 30.days.ago.iso8601
    @end_date   = Time.now.iso8601

    service = GithubService.new

    @results = {}

    @repos.each do |repo|
      @results[repo] = {}

      @users.each do |user|
        info = service.get_commit_info(repo, user, @start_date, @end_date)

        @results[repo][user] = info.commit_count
      end
    end
  end
end
