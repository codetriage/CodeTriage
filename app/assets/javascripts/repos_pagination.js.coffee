$ ->
  $pagination = $('#issues')
  $pagination.on "click", "a", ->
    $.get this.href, null, null, 'script'
    return false