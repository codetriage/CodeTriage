jQuery(document).ready(function(){
  new Codetriage.TabNavigation();
  new Codetriage.previewLinkBuilder();

  // hash reference to select a specific list
  var hash = document.location.hash;

  if (hash) {
  	$('.nav-tabs a[href='+hash+']').tab('show');
  }

  // exits search component?
  var searchRepo = $("#input-repo");
  if (searchRepo.length) {

  	// make un array finding html elements
  	var arrayRepos = makeArray ();
  	// add function to reset elements to show
  	arrayRepos.reset = function () {
  		$.each (this, function (index, element) {
  			element.show = true;
  		});
  	};

  	$("#search-repo").click(function() {
  		var search = $.trim (searchRepo.val ());
  		if (search !== '') {
  			determineVisibility (arrayRepos, search.toLowerCase());
  		} else {
  			arrayRepos.reset ();
  		}
  		hideShowRepos (arrayRepos);
  	});
  }
});

function makeArray () {
  	var reposToFind = [];
  	// find current tab
  	var reposList = $('#tab-repo .tab-pane.active ul > li');

  	// make an array with obj to find repos
  	$.each (reposList, function (index, value) {
  		reposToFind.push({
  			id: $(value).attr ('id'),
  			name: $(value).data ('name'),
  			description: $(value).data ('description'),
  			show: true
  		});
  	});

  	return reposToFind;
}

function determineVisibility (arrayRepos, search) {
	$.each (arrayRepos, function (index, element) {
		// exactly name
		var byName = element['name'] === search;
		var byDesc = element['description'].toLowerCase().search(search) >= 0;
		// add new attr which determine whether is shown or not
		element.show = byName || byDesc;
	});
}

function hideShowRepos (arrayRepos) {
	$.each (arrayRepos, function (index, element) {
		if (element['show']) {
			$('#repos-list #' + element['id']).show ();
		} else {
			$('#repos-list #' + element['id']).hide ();
		}
	});
}