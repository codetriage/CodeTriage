require "test_helper"

class UniversityControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get university_index_url
    assert_response :success
    assert(response.body.include?("Open Source Contribution University"))
  end
  test "should get show /squash" do
    get '/squash'
    assert_response :success  
    assert(response.body.include?("Please squash your commits"))
  end
  test "should get show /example_app" do
    get '/example_app'
    assert_response :success
    assert(response.body.include?("Please Provide an Example App"))
  end
  test "should show /reproduction" do
    get '/reproduction'
    assert_response :success
    assert(response.body.include?("Please Provide Reproduction Code"))
  end

  test "should show /repro" do
    get '/repro'
    assert_response :success
    assert(response.body.include?("Please Provide Reproduction Code"))
  end
  test "should show /rebase" do
    get '/rebase'
    assert_response :success
    assert(response.body.include?("Please Rebase your commits"))
  end
  test "should show /picking_a_repo" do
    get '/university/picking_a_repo'
    assert_response :success
    assert(response.body.include?("Picking the Right Repo(s) to start your Open Source Contribution Journey"))
  end
end
