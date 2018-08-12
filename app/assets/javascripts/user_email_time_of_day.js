
// Display options in select box in local time
$(document).ready(function(){

  $("#user_email_time_of_day option")
    .toArray()
    .forEach(function(element) {
      var time = new Date(element.value);
      element.text = LocalTime.strftime(time, "%H:%M %Z");
    })

  $("#user_email_time_of_day").html($("#user_email_time_of_day option").sort(function (a, b) {
    return a.text == b.text ? 0 : a.text < b.text ? -1 : 1
  }))

});
