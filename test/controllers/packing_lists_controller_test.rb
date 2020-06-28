require 'test_helper'

class PackingListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get packing_lists_index_url
    assert_response :success
  end

  test "should get show" do
    get packing_lists_show_url
    assert_response :success
  end

  test "should get new" do
    get packing_lists_new_url
    assert_response :success
  end

  test "should get create" do
    get packing_lists_create_url
    assert_response :success
  end

  test "should get upload" do
    get packing_lists_upload_url
    assert_response :success
  end

end
