var arrayRepos = [];

jQuery(document).ready(function(){
	new Codetriage.TabNavigation();
	new Codetriage.previewLinkBuilder();

	// hash reference to select a specific list
	var hash = document.location.hash;

	if (hash) {
		$('.nav-tabs a[href='+hash+']').tab('show');
	}

	// add function to reset elements to show
	Array.prototype.reset = function () {
		$.each (this, function (index, element) {
			element.show = true;
		});
	};

	// exits search component?
	var searchRepo = $("#input-repo");
	if (searchRepo.length) {
		// first loading
		arrayRepos = makeArray ($("#tab-repo .tab-pane.active").first());
	}

	var onSearch = function() {
		var search = $.trim (searchRepo.val ());
		if (search !== '') {
			determineVisibility (arrayRepos, search.toLowerCase());
		} else {
			arrayRepos.reset ();
		}
		hideShowRepos (arrayRepos);
	};

	// register events on search component
	$("#search-repo").click(onSearch);
	$("#input-repo").keypress(function (e) {
		if (e.which == 13) {
			onSearch ();
			return true;
		}
	});
});

function filter (tab) {
	arrayRepos = makeArray (tab);
	arrayRepos.reset ();
	hideShowRepos (arrayRepos);
	$("#input-repo").val ('');
}


function makeArray (tab) {
	var array = [];
	// find current tab
	var reposList = $(tab).find('ul > li');

	// make an array with obj to find repos
	$.each (reposList, function (index, value) {
		array.push({
			id: $(value).attr ('id'),
			name: $(value).data ('name'),
			description: $(value).data ('description'),
			show: true
		});
	});

	return array;
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
			$('#repos-list #' + element['id']).fadeIn();
		} else {
			$('#repos-list #' + element['id']).fadeOut();
		}
	});
}