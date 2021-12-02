require "test_helper"

class ApiInfoControllerTest < ActionDispatch::IntegrationTest
  def setup
    @repo = repos(:get_process_mem)
  end
  test "show user" do
    assert get api_info_url({
      user_name:@repo.user_name, 
      name:@repo.name,
      full_name:@repo.full_name,
      language:@repo.language,
      created_at:@repo.created_at,
      updated_at:@repo.updated_at,
      issues_count:@repo.issues_count,
      commit_sha:@repo.commit_sha,
    })
  end

end
