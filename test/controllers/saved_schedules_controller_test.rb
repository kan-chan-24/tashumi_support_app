require "test_helper"

class SavedSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get saved_schedules_show_url
    assert_response :success
  end
end
