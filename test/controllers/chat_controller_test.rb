require 'test_helper'

class ChatControllerTest < ActionController::TestCase
  test "should get chat" do
    get :chat
    assert_response :success
  end

end
