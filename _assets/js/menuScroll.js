/*

Scroll a menu to match a heading in the main content

## Details

Loops over all h2 and h3 tags in the text and generates a menu from them.

As the page scrolls, the current heading is highlighted (class=hi added).

Clicking on the menu will scroll to the selected heading with an animation.

## Usage

Create an empty div to hold the menu and ensure your text has h2 and h3 tags for the headings.

Apply this to the empty div with a selector for the content (var is "maincontent" to avoid confusion with content of menu). 

You can adjust the "offset" for the scroll by supplying a numeric value, otherwise it uses the top of the content div.

E.g. 

```
$("#mymenu").menuScroll({maincontent:"#main", offset: $("#header").height()});
```
*/

(function($) {

	$.menuScroll = function(element, options) {

		var defaults = {
			maincontent:"body",
	        offset:"auto",
	        debug: false
		}

		// to avoid confusions, use "plugin" to reference the
		// current instance of the object
		var plugin = this;

		plugin.settings = {}

		var $element = $(element), // reference to the jQuery version of DOM element
		element = element; // reference to the actual DOM element
		var $maincontent; // refence to text content container

		plugin.init = function() {

			plugin.settings = $.extend({}, defaults, options);
			
			$maincontent = $(plugin.settings.maincontent);
			if (plugin.settings.offset == "auto") {
				plugin.settings.offset = $maincontent.offset().top;
			}
			
			// check main content headings for anchors
			generateMenu();

			// trigger immediate run
			scrollMenu();

			// could do with throttling
			$(window).on('scroll', function() {
				scrollMenu();
			});

			$element.on("click","a", function(e) {
				e.preventDefault();
			   	const id = $(this).attr("href");
			   	plugin.scrollToAnchor(id);
			});

		}

		plugin.scrollToAnchor = function(aid) {
			const $aTag = $(aid);
		    $('html,body').animate({scrollTop: $aTag.offset().top - plugin.settings.offset},'slow',function() {
		    	scrollMenu();	
		    });
		}

		var generateMenu = function() {
			
			var count = 1;
			var menuItems = [];
			var currentId = "";

			$maincontent.find("h2,h3").each(function() {
				
				const $heading = $(this);
				const tagName = $heading.prop("tagName");
				const id = $heading.attr('id') || "heading_" + (count++);
				
				if (tagName == "H2") {
					menuItems.push({"id":id,"text":$heading.text(),"submenus":[]});
				}
				else {
					// if there's no h2 tag before and h1 we have to add a "top" entry and use that for subment
					if (! menuItems.length) {
						menuItems.push({"id":"top","text":"Top","submenus":[]});
					}
					menuItems[menuItems.length-1].submenus.push({"id":id,"text":$heading.text()});
				}

			});

			var menuHtml = "<ul>";
			
			for (let menu of menuItems) {
				menuHtml += "<li id='headingmenu_" + menu.id + "'><a href='#" + menu.id + "'>" + menu.text + "</a>";
				if (menu.submenus.length) {
					menuHtml += "<ul class='submenu open'>";
					for (let submenu of menu.submenus) {
						menuHtml += "<li id='headingmenu_" + submenu.id + "'><a href='#" + submenu.id + "'>" + submenu.text + "</a></li>";
					}
					menuHtml += "</ul>";
				}
				menuHtml += "</li>";
			}
			menuHtml += "</ul>";
			
			$element.html(menuHtml);

		}

		var scrollMenu = function() {

			var first = true;
			var selected = '';

			$maincontent.find("h2,h3").each(function() {

				let anchor_offset = $(this).offset().top;
				let top = $(window).scrollTop() + plugin.settings.offset;

				let name = $(this).attr('id');
				
				//  #DEBUG
				if (plugin.settings.debug) {
					console.log(name, "top=", top, "anchor_offset=", anchor_offset);
				}
				// /#DEBUG
				if (first && (top <= anchor_offset ))  {
		    		selected = name;
		        	first = false;
		        	// #DEBUG
		        	if (plugin.settings.debug) {
			        	console.log("Setting selected to " + selected);
			        }
			        // /#DEBUG
		        }
		        // #DEBUG
		        else if (first && plugin.settings.debug) {
		        	console.log("off screen");
		        }
		        // /#DEBUG
		    });

		    $element.find('.hi').each(function() {
		    	$(this).removeClass('hi');
		    });
		    
		    // TODO: only one open option
		    // $element.find('.submenu.open').each(function() {
		    // 	$(this).removeClass('open');
		    // });
		    
		    if (selected != '') {
		    	$element.find('#headingmenu_' + selected).addClass('hi');
		    }

		}

		plugin.init();

	}

	$.fn.menuScroll = function(options) {

		return this.each(function() {

			if (undefined == $(this).data('menuScroll')) {

				var plugin = new $.menuScroll(this, options);

				$(this).data('menuScroll', plugin);

			}

		});

	}

})(jQuery);