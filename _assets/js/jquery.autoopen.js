/*

# Auto open function

Apply open and close handlers to an element

Will add open class on open, close class on close, and eventually animate width|height

## Synopsis

## Details

@author Tom Peer
@version 1.0

*/

(function($) {

	$.autoopen = function(element, options) {

		// plugin's default options
		// this is private property and is accessible only from inside the plugin
		var defaults = {

			animate: "horizontal", 
			animationTime: 600,
			open: false,
			resize: "resize"
			
		}

		var settingTypes = {
			animate: "string",
			animationTime: "integer",
			open: "boolean"
		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), // reference to the jQuery version of DOM element
			element = element; // reference to the actual DOM element

		plugin.init = function() {
			var id = $element.attr("id");
			plugin.settings = $.extend(true, {}, defaults, options);
			
			getCssSettings();
			
			setOpenClass();

			$(window).on(plugin.settings.resize,function() {
				$element.trigger("resize");
			});

		}

		$element.on("open",function(e) {
			e.stopPropagation();
			plugin.settings["open"] = true;
			console.log("Opening " + $element.attr("id"));
			setOpenClass();
			
		});

		$element.on("close",function(e) {
			e.stopPropagation();
			console.log("Closing " + $element.attr("id"));
			plugin.settings["open"] = false;
			setOpenClass();
			
		});

		$element.on("resize",function(e) {
			console.log("Resizing" + $element.attr("id"));
			e.stopPropagation();
			getCssSettings();
			setOpenClass();
		});
		
		var setOpenClass = function() {
			if (plugin.settings.open) {
				$element.addClass("open").removeClass("closed");
			}
			else {
				$element.addClass("closed").removeClass("open");
			}
		}
    	var getCssSettings = function() {
			
			var settings = clik.parseCssVars($element,settingTypes);
			for (let setting in settingTypes) {
				if (setting in settings)  {
					let val = settings[setting];
					if (setting == "animate") {
						if (val != "width" && val != "height" ) {
							val = "none";
						}
					}
					plugin.settings[setting] = settings[setting];
				}
			}

		}
		
		plugin.init();

	}

	$.fn.autoopen = function(options) {

		return this.each(function() {

			if (undefined == $(this).data('autoopen')) {

				var plugin = new $.autoopen(this, options);

				$(this).data('autoopen', plugin);

			}

		});

	}

})(jQuery);