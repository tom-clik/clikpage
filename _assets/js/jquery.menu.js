/**
 * Menu function
 *
 * Add arrow icon to any items with a sub menu
 *
 * Ad onclick to those items that adds an open class to the sub menu.
 *
 * TODO:
 *
 * 1. Auto animate height of sub menus
 * 2. Position sub menus for any that aren't inline
 * 
 */

$.fn.menu = function(ops) {
 	
	var defaults = {
			debug: false,
			arrow: "<i class='icon icon-next openicon'></i>",
			menuAnimationTime: "0.3s"
		},
		options = $.extend({},defaults,ops);

	$(".submenu").on("open",function() {
		var id = $(this).attr("id");
		console.log("opening " + id);
		
		// close children
		$(this).find("ul.submenu").each(function() {
			let $childmenu = $(this);
			if ($childmenu.hasClass("open")) {
				$childmenu.trigger("close");
			}
		});

		$(this).animateAuto("height", options.menuAnimationTime, function() {
			console.log("Open animation complete for " + id);	
			$(this).css({"height":""}).addClass("open");
		});
		return false;

	}).on("close",function() {
		var id = $(this).attr("id");
		console.log("closing " + id);
		$(this).animate({"height":0}, options.menuAnimationTime, function() {
			console.log("Close animation complete for " + id);	
			$(this).removeClass("open").css({"height":""});
		});
		return false;
	});
	

	return this.each(function() {
    	var self = this;
			
		$(self).find(".submenu").each(function() {
			$(this).prev("a").append(options.arrow).addClass("hasmenu");
		});

		$(self).on("click",".hasmenu",function(e) {
			
			console.log("opening submenu");

			e.preventDefault();
			e.stopPropagation(); 
			
			var $li = $(this).closest("li");
			var open = $li.hasClass("open");
			
			// close siblings
			$(this).closest("ul").find("li").each(function() {
				if ($(this).hasClass("open")) {
					let $submenu = $(this).find("> ul").first();
					$submenu.trigger("close");
					$(this).removeClass("open");
				}
			});
			
			var $submenu = $li.find("> ul").first();

			if (!open) {
				$li.addClass("open");
				console.log($submenu.html());
				$submenu.trigger("open");
			}
			else {
				$submenu.trigger("close");	
			}
			
			return false;

		});

		$(self).on("open",function(){
			console.log(options);
			console.log("opening " + $(self).attr("id"));
			$(self).show().animateAuto("height", options.menuAnimationTime, function() {
				console.log("Animation complete");	
				$(self).css({"height":"auto"});
			});
		}).on("close",function(){
			console.log("closing " + $(self).attr("id"));
			$(self).animate({"height":0}, options.menuAnimationTime, function() {
				console.log("Animation complete");	
				$(self).css({"height":0}).hide();
			});
		});
		
	});
}
