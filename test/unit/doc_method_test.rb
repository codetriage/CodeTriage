require "test_helper"

class DocMethodTest < ActiveSupport::TestCase

  def setup
    @doc_method = doc_methods(:issue_triage_doc)

  end 
  test "should create doc_method" do  
    assert @doc_method.save 
  end

  test "don´t create a blank DocMethod" do
    doc_method = DocMethod.new
    assert_equal(false, doc_method.valid?)
    assert_equal(false, doc_method.save)
  end

  test "don´t create a DocMethod without a name" do
    
    @doc_method.name = nil
    assert_equal(false, @doc_method.valid?)
    assert_equal(false, @doc_method.save)
  end

  test "don´t create a DocMethod without a raw_file" do
    
    @doc_method.file = nil
    assert_equal(false, @doc_method.valid?)
    assert_equal(false, @doc_method.save)
  end

  test "don´t create a DocMethod without a path" do
    
    @doc_method.path = nil
    assert_equal(false, @doc_method.save)
  end

  test "missing_docs?" do
    @doc_method.doc_comments.destroy_all
    assert_equal(true, @doc_method.missing_docs?)
  end

  test "doc_method to GithubUrlFromBasePathLine" do
    assert_equal(GithubUrlFromBasePathLine.new(@doc_method.repo.github_url, @doc_method.repo.commit_sha, @doc_method.file, @doc_method.line).to_github, 
                @doc_method.to_github)
  end

  test "self.active test should returns true with active doc_method" do
    @doc_method.update_attribute(:active, true)
    @doc_method.save
    
    assert DocMethod.active.include?(@doc_method)

  end

  test "self.active test should returns empty without active focs" do    
    DocMethod.all.each do |doc_method|
      doc_method.update_attribute(:active, false)
    end 
    assert_equal(true, DocMethod.active.empty?)
  end



end
