require 'test_helper'

class PlacementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get placements_index_url
    assert_response :success
  end

  test "should get show" do
    get placements_show_url
    assert_response :success
  end

end
