namespace 'Codetriage', (exports) ->
  class exports.previewLinkBuilder
    constructor: (customOptions = {}) ->
      defaultOptions = {
        "userNameInput"     : ".preview_user_name",
        "userRepoNameInput" : ".preview_repo_name",
        "previewLink"       : "#repo_preview"
      }

      @options = $.extend({}, defaultOptions, customOptions)
      @repoPreviewAnchorTag = $("#{@options.previewLink} > a")
      @updatePreviewLink()
      @updatePreviewLinkOnKeyup()

    createGithubUrl: ->
      userName = $(@options.userNameInput).val()?.trim()
      repoName = $(@options.userRepoNameInput).val()?.trim()
      "https://github.com/#{userName}/#{repoName}"

    checkPreviewUrl: ->
      if @repoPreviewAnchorTag.attr('href')  == "https://github.com//"
        $(@options.previewLink).fadeOut(300)
      else
        $(@options.previewLink).fadeIn(300)

    updatePreviewLink: ->
      @repoPreviewAnchorTag.html(@createGithubUrl()).attr('href',@createGithubUrl())
      @checkPreviewUrl()

    updatePreviewLinkOnKeyup: ->
      $(document).delegate @options.userNameInput, "keyup", =>
        @updatePreviewLink()

      $(document).delegate @options.userRepoNameInput, "keyup", =>
        @updatePreviewLink()