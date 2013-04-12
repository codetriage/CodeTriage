jQuery ->
  $(".alert-message").alert()
  $(".tabs").button()
  $(".carousel").carousel()
  $(".collapse").collapse()
  $(".dropdown-toggle").dropdown()
  $(".modal").modal()
  $("a[rel]").popover()
  $(".navbar").scrollspy()
  $(".tab").tab "show"
  $("[data-toggle=tooltip]").tooltip()
  $(".typeahead").typeahead()

  $("#repo-tabs a:first").tab 'show'

  $("a[href=" + location.hash + "]").tab "show"  if location.hash
  
  $(document.body).on "click", "a[data-toggle]", (e) ->
    location.hash = @getAttribute("href")
    e.preventDefault()

  $(window).on "popstate", ->
    anchor = location.hash or $("a[data-toggle=tab]").first().attr("href")
    $("a[href=" + anchor + "]").tab "show"
