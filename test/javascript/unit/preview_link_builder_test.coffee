describe "Codetriage.previewLinkBuilder", ->
  beforeEach ->
    fixture.load("../fixtures/preview_link_builder_test_fixture.html")
    @previewUrl = new Codetriage.previewLinkBuilder()

  it "should update the preview url on keyup", ->
    $('.preview_user_name').val('my_username')
    $('.preview_repo_name').val('my_repo')
    $('.preview_repo_name').keyup()
    assertjs.equal("https://github.com/my_username/my_repo", $('.repo_preview a').attr('href'),
      "expected #repo_preview anchor tag url to match")