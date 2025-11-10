require "test_helper"

class GithubControllerTest < ActionDispatch::IntegrationTest
  test "should get webhook" do
    get github_webhook_url
    assert_response :success
  end
end
