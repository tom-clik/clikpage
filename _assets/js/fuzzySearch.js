/*

# fuzzySearch

Client side fuzzy match search. Uses list of supplied text strings to do a fuzzy match on  search term. 

E.g.  ts would match  Technical Solutions

## Synopsis

Loops over all data an does fuzzy match on text string to get score. These are pushed to a results array which is then sorted by the score.

The results are then displayed with correct links

## Usage

The data (options.symbols) needs to be an array of objects with keys title, id, and section.

Apply the plug in to a input elements, and supply the jquery selector for the results div in options.results

Requires fts_fuzzy_match.js

### Sample

```javascript
$("#fuzzySearch").fuzzySearch({symbols:symbols, results: "#searchResults"})
````

*/
(function($) {

	$.fuzzySearch = function(element, options) {

		var defaults = {
			cache : true
		};

		var plugin = this;
		plugin.settings = {};

		var $element = $(element), 
		element = element; 

		var $searchResults;

		plugin.init = function() {

			plugin.settings = $.extend({}, defaults, options);

			if ("results" in options) {
				$searchResults = $(options.results);
			}
			else {
				console.warn("Results not found");
				$searchResults = $("<div></div>").appendTo($element);
			}

			$element.on("keydown",
				function(e) {
					if (e.key === 'Enter') {
						e.preventDefault();
						e.stopPropagation();
					}
				})
				.on("keyup",function(e) {
					e.preventDefault();
					e.stopPropagation();
					var auto = false;
					console.log(e.key);
					if (e.key === 'Escape') {
						$(this).val("");
					}
					else if (e.key === 'Enter') {
						auto = true;
					}

					plugin.search($(this).val(), auto);

				});

			
		}

		plugin.search = function(text,auto) {
			
			auto = auto || false;

			var results = [];

			if (text == "") {
				$searchResults.addClass("empty");
				return;
			}
			
			for (var i in plugin.settings.symbols) {
			    var res = fuzzyMatch(text,plugin.settings.symbols[i].title);
			    if (res[0]) {
			    	results.push({pos:i,score:res[1]});
			    }
			}

			$searchResults.removeClass("empty");
			
			var html = "";

			if (results.length == 0) {
				html = "<p>No results found</p>";
			}

			results.sort(function(a,b) {
			    return b.score - a.score;
			});

			console.log(results);

			for (let res of results) {
				var symbol = plugin.settings.symbols[res.pos];
				var anchor = symbol.id !== symbol.section ? '#' + symbol.id : '';
				var link = plugin.settings.cache ? symbol.section + ".html" : "index.cfm?code=" + symbol.section;
				link +=  anchor;
				if (plugin.settings.auto) {
					window.location.href = link;
					return;
				}
				html += "<p><a href='" + link + "'>" + symbol.title + "</a></p>";
			}

			console.log(html);

			$searchResults.html(html);
		}

		plugin.init();

	}

	// add the plugin to the jQuery.fn object
	$.fn.fuzzySearch = function(options) {

		// iterate through the DOM elements we are attaching the plugin to
		return this.each(function() {

		  // if plugin has not already been attached to the element
		  if (undefined == $(this).data('fuzzySearch')) {

			  var plugin = new $.fuzzySearch(this, options);

			  $(this).data('fuzzySearch', plugin);

		   }

		});

	}

})(jQuery);
