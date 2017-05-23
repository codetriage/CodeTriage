$('.nav-tabs li a').click(function(e){
  e.preventDefault();
  e.stopImmediatePropagation();
  $(this).tab('show');
});
