jQuery(function() {
  $("a[rel=popover]").popover();
  $(".tooltip").tooltip();
  $("a[rel=tooltip]").tooltip();
});

window.setTimeout(function() {
  $(".alert").slideUp(500, function(){
      $(this).remove();
  });
}, 5000);
