$(function() {
  $(".modal select").change(function(){
    $(".modal textarea").hide()
    $(".modal textarea." + $( this ).val()).show()
  })
})
