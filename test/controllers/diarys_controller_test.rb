require 'test_helper'

class DiarysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get diarys_index_url
    assert_response :success
  end

  test "should get show" do
    get diarys_show_url
    assert_response :success
  end

end
