class GithubController < ApplicationController
  skip_before_action :verify_authenticity_token
  def webhook
    payload = request.body.read

    event = request.headers['X-GitHub-Event']
    data = JSON.parse(payload)
  
    case event 
    when 'push'
      handle_push_event(data)
    end

    head :ok
  end

  private 
  
  def handle_push_event(data)
    repo_name = data['repository']['full_name']
    commit_count = data['commits'].size

    repo = Repository.find_or_create_by(name: repo_name)
    repo.increment!(:commit_count, commit_count)
  end
end
