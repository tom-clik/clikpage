/*

Scroll a menu to match a heading in the main content

## Details

Loops over all h2 and h3 tags in the text and generates a menu from them.

As the page scrolls, the current heading is highlighted (class=hi added).

Clicking on the menu will scroll to the heading selected with an animation.

## Usage

Create an empty div to hold the menu and ensure your text has h2 and h3 tags for the headings.

Apply this to the empty div with a selector for the content and an offset height.

E.g. 

```
$("#mymenu").menuScroll({"maincontent":"#maincol", $("#header").height()});
```
*/

$.fn.menuScroll = function(options) {
	
	var $menu = this;

	var settings = $.extend({
        maincontent:"body",
        headerheight:0
    }, options );

	var $maincontent = $(settings.maincontent);

	if (settings.headerheight == "auto") {
		settings.headerheight = $maincontent.offset().top;
	}

	// check main content headings for anchors
	generateMenu();
	
	// trigger immediate run
	scrollMenu($menu,$maincontent);

	// could do with throttling
	$(window).on('scroll', function() {
		scrollMenu($menu,$maincontent);
	});

	$menu.on("click","a", function(e) {
		e.preventDefault();
	   	var id = $(this).attr("href");
	   	scrollToAnchor(id.replace("#",""));
	});

	function scrollToAnchor(aid){
	    var aTag = $("a[name=" + aid + "]");
	    $('html,body').animate({scrollTop: aTag.offset().top - settings.headerheight},'slow',function() {
	    	scrollMenu($menu,$maincontent);	
	    });
	}

	function generateMenu() {
		var count = 1;
		var menuItems = [];
		var currentId = "";
		$maincontent.find("h2,h3").each(function() {
			
			var $heading = $(this);
			var tagName = $heading.prop("tagName");
			var id = $heading.attr('id') || "heading_" + (count++);
			
			if (tagName == "H2") {
				menuItems.push({"id":id,"text":$heading.text(),"submenus":[]});
			}
			else {
				if (! menuItems.length) {
					menuItems.push({"id":"top","text":"Top","submenus":[]});
				}
				menuItems[menuItems.length-1].submenus.push({"id":id,"text":$heading.text()});
			}

			// check headings in main content have an anchor
			var a = $heading.find("a").first();
			
			if (! a.length) {
				$heading.html("<a name='" + id + "'>" + $heading.html() + "</a>") ;
			}
			else {
				var aid = a.attr('id') || id;
				var name = a.attr("name");
				if (! name) {
					a.attr("name",aid);
				}
			}

		});

		var menuHtml = "<ul>";
		console.log(menuItems);
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
		
		$menu.html(menuHtml);

	}
	
	function scrollMenu($menu, $maincontent) {

		var first = true;
		var id;
		var selected = '';

		$maincontent.find("h2 a,h3 a").each(function() {

			var anchor_offset = $(this).offset().top;
			var top = $(window).scrollTop() + settings.headerheight;

			name = $(this).attr('name');
			
			console.log(name, "top=", top, "anchor_offset=", anchor_offset);

			if (first && (top <= anchor_offset ))  {
	    		selected = name;
	        	first = false;
	        	console.log("Setting selected to " + selected);

	        }
	        // #DEBUG
	        else if (first) {
	        	console.log("off screen");
	        }
	        // /#DEBUG
	    });

	    $menu.find('.hi').each(function() {
	    	$(this).removeClass('hi');
	    });
	    // $menu.find('.submenu.open').each(function() {
	    // 	$(this).removeClass('open');
	    // });
	    
	    if (selected != '') {
	    	$menu.find('#headingmenu_' + selected).addClass('hi');
	    	// $menu.find('#headingmenu_' + selected + " .submenu").addClass('open');
	    }

	}
};

