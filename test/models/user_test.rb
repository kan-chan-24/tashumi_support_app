require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "strips whitespace from nickname" do
    user = User.new(nickname: "  taro  ")
    assert_equal("taro", user.nickname)
  end
end
