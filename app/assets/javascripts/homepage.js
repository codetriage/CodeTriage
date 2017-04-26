// JS for the buttons on the home page
$(document).ready(function(){
  $(".types-filter-button").click(function() {
    $(".types-filter").toggle();
  });

  $(".types-filter > li a").click(function(e){
    e.preventDefault();

    $(".types-filter").hide();
    var language = this.getAttribute("data-language");
    $(".types-filter-button").html(language);
    updateQueryStringParam("language", language);
    removeQueryStringParam("page");

    $.ajax({
      url: document.URL,
      headers: {
        Accept :        "application/json; charset=utf-8",
        "Content-Type": "application/json; charset=utf-8"
      },
      beforeSend: function () {
        // go
      },
    }).done(function(data) {
      $('.repo-list-with-pagination').html(data["html"]);
    }).fail(function(data){
      console.log(data);
    });

    return false;
  });
})

function baseUrl() {
  return [location.protocol, '//', location.host, location.pathname].join('');
}

function removeQueryStringParam(param) {
  var urlQueryString = document.location.search;

  if (urlQueryString) {
    keyRegex = new RegExp('&?' + param + '[^&]*');
    params = urlQueryString.replace(keyRegex, '');
  }

  window.history.replaceState({}, '', baseUrl() + params);
}

function updateQueryStringParam(param, value) {
  urlQueryString = document.location.search;
  var newParam = param + '=' + encodeURIComponent(value),
  params = '?' + newParam;

  // If the "search" string exists, then build params from it
  if (urlQueryString) {
    keyRegex = new RegExp('([\?&])' + param + '[^&]*');
    // If param exists already, update it
    if (urlQueryString.match(keyRegex) !== null) {
      params = urlQueryString.replace(keyRegex, "$1" + newParam);
    } else { // Otherwise, add it to end of query string
      params = urlQueryString + '&' + newParam;
    }
  }
  window.history.replaceState({}, "", baseUrl() + params);
};