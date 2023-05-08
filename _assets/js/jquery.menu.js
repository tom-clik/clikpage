/**
 * # Menu function
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

(function($) {

	$.menu = function(element, options) {

		var defaults = {
			debug: false,
			arrow: "<i class='icon icon-next openicon'></i>",
			animate: "none", // animate "width", "height" or "both". Use when these CSS props are "auto" and you can use CSS animations
			menuAnimationTime: "0.3s",
			onOpen: function() {},
			onClose: function() {}
		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), 
			element = element; 

		plugin.init = function() {

			// the plugin's final properties are the merged default and
			// user-provided options (if any)
			plugin.settings = $.extend({}, defaults, options);

			// code goes here
			$element.find(".submenu").each(function() {
				let $submenu = $(this);
				$submenu.prev("a").append("<i class='icon'>" + plugin.settings.arrow + "</i>").addClass("hasmenu");
				$submenu.on("open",function(e) {
					e.stopPropagation();
					$(this).addClass("open");
				}).on("close",function(e) {
					e.stopPropagation();
					$(this).removeClass("open");
				});
			});

			$element.on("click",".hasmenu .icon",function(e) {
				
				$item = $(this);
				e.preventDefault();
				e.stopPropagation(); 
				
				var $li = $item.closest("li");
				var open = $li.hasClass("open");
				
				// close siblings
				$li.closest("ul").find("li").each(function() {
					if ($(this).hasClass("open")) {
						let $submenu = $(this).find("> ul").first();
						$submenu.trigger("close");
						$(this).removeClass("open");
					}
				});
				
				var $submenu = $li.find("> ul").first();

				if (!open) {
					$li.addClass("open");
					$submenu.trigger("open");
				}
				else {
					$submenu.trigger("close");	
				}
				
				return false;

			});
		}

		plugin.init();

	}

	$.fn.menu = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('menu')) {

			  var plugin = new $.menu(this, options);

			  $(this).data('menu', plugin);

		   }

		});

	}

})(jQuery);