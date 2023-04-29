function search(text,$rescont,cache,auto) {

	cache = cache || false;
	auto = auto || false;

	var results = [];

	if (text == "") {
		$rescont.addClass("empty");
		return;
	}
	
	for (var i in symbols) {
	    var res = fuzzyMatch(text,symbols[i].title);
	    if (res[0]) {
	    	results.push({pos:i,score:res[1]});
	    }
	}

	$rescont.removeClass("empty");
	
	var html = "";

	if (results.length == 0) {
		html = "<p>No results found</p>";
	}

	results.sort(function(a,b) {
	    return b.score - a.score;
	});

	
	for (let res of results) {
		var symbol = symbols[res.pos];
		var anchor = 'anchor' in symbol ? '#' + symbol.anchor : '';
		var link = cache ? "../" + symbol.pub + "/" + symbol.code + ".html" : "index.cfm?pub=" + symbol.pub + "&code=" + symbol.code;
		link +=  anchor;
		if (auto) {
			window.location.href = link;
			return;
		}
		html += "<p><a href='" + link + "'>" + symbol.title + "</a></p>";
	}

	$rescont.html(html);

}

