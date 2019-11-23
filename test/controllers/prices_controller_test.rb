require 'test_helper'

class PricesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prices_index_url
    assert_response :success
  end

  test "should get new" do
    get prices_new_url
    assert_response :success
  end

  test "should get create" do
    get prices_create_url
    assert_response :success
  end

  test "should get update" do
    get prices_update_url
    assert_response :success
  end

  test "should get edit" do
    get prices_edit_url
    assert_response :success
  end

  test "should get show" do
    get prices_show_url
    assert_response :success
  end

end
