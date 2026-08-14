require "test_helper"

class SavedSchedulesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "should get show" do
    get saved_schedule_url
    assert_response :success
  end
end
