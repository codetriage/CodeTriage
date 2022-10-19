# frozen_string_literal: true

require 'test_helper'

class GithubFetcher::ResourceTest < ActiveSupport::TestCase
  def status_validation(mocked_status, method, expected_response)
    GithubFetcher::Resource.any_instance.stubs(:status).returns(mocked_status)
    resource = GithubFetcher::Resource.new({})
    assert_equal expected_response, resource.send(method)
  end

  test '#not_found? is true on 404 status responses' do
    status_validation(404, :not_found?, true)
  end

  test '#not_found? is false on non 404 status responses' do
    [200, 201, 204, 400, 403, 500, 502].each { |status| status_validation(status, :not_found?, false) }
  end
end
