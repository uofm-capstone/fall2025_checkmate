class GithubController < ApplicationController
  skip_before_action :verify_authenticity_token
  def webhook
    payload = request.body.read

    data = JSON.parse(payload)
    if data['commits']
      repo = data['repository']['full_name']
      commit_count = data['commits'].size
    end

    head :ok
  end
end
