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
			hilight: "",
			arrow: "<i class='icon-next openicon'></i>",
			animate: "none", // animate "width", "height" or "both". Use when these CSS props are "auto" and you can't use CSS animations
			menuAnimationTime: "0.3s",
			onOpen: function() {},
			onClose: function() {}
		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), 
			element = element,
			props = {};

		plugin.init = function() {

			// the plugin's final properties are the merged default and
			// user-provided options (if any)
			
			let temp = $.extend({}, defaults, options);
			let cssVars = getCssSettings($element,"hilight,arrow,animate,menuAnimationTime");
			plugin.settings = $.extend({}, temp, cssVars);

			console.log(plugin.settings);

			switch(plugin.settings.animate) {
				case "height":
					props.height = 0;
					break;
				case "width":
					props.width = 0;
					break;
				case "both":
					props.width = 0;
					props.height = 0;
					break;
			}
			// code goes here
			$element.find(".submenu").each(function() {
				let $submenu = $(this);
				$submenu.prev("a").append( plugin.settings.arrow ).addClass("hasmenu");
				$submenu.on("open",function(e) {
					e.stopPropagation();
					$submenu.addClass("open").animateAuto(plugin.settings.animate, plugin.settings.menuAnimationTime,function() {
						$submenu.css({"height":"auto"});
					});
				}).on("close",function(e) {
					e.stopPropagation();
					console.log(props);
					$submenu.removeClass("open").animate(props, plugin.settings.menuAnimationTime, function() {});
				});
			});

			$element.on("click",".hasmenu .openicon",function(e) {
				
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

			if (plugin.settings.hilight !== "") {
				let $a = $("#menu_" + plugin.settings.hilight);
				let $li = $a.closest("li");
				let $menu = $a.closest("ul");
				$li.addClass("hi");
				if ($a.hasClass("hasmenu") ) {
					let $submenu = $a.find("> ul").first();
					$li.addClass("open");
					$submenu.trigger("open");
				}
				if ($menu.hasClass("submenu")) {
					let $parent = $menu.closest("li");
					$parent.addClass("open");
				}
			}
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