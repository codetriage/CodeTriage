namespace 'Codetriage', (exports) ->
  class exports.TabNavigation
    constructor: (options = {}) ->
      @tabItem      = $("a[data-toggle]")
      @locationHash = location.hash
      @defaultLocation() unless @locationHash
      @watchHistory()
      @bindDataToggleTabEvent()
      @showTabLocation() if @locationHash

    defaultLocation: ->
      $("#repo-tabs a:first").tab 'show'

    watchHistory: ->
      $(window).on "popstate", =>
        @locationHash = location.hash or @tabItem.first().attr("href")
        @showTabLocation()

    bindDataToggleTabEvent: ->
      @tabItem.on "click", (event) =>
        event.preventDefault()
        @locationHash = $(event.target).attr('href')
        location.hash = @locationHash
        @showTabLocation()

    showTabLocation: ->
      $("a[href='#{@locationHash}']").tab "show"