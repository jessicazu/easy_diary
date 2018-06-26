require 'test_helper'

class DiariesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get diaries_index_url
    assert_response :success
  end

  test "should get show" do
    get diaries_show_url
    assert_response :success
  end

end
