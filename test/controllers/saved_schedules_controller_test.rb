require "test_helper"

class SavedSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get saved_schedule_url
    assert_response :success
  end
end
