$ ->
  $('.digg_pagination a').click ->
    $.get this.href, null, null, 'script'
    console.log $('.digg_pagination em.current')
    return false