/*

# Auto open function

Apply open and close handlers to an element

Will add open class on open and eventually animate width|height

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
			open: true,
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

			plugin.settings = $.extend({}, defaults, options);
			
			getCssSettings();
			
			setOpenClass();

			$(window).on(plugin.settings.resize,function() {
				console.log("Window resize");
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
			plugin.settings["open"] = false;
			setOpenClass();
			
		});

		$element.on("resize",function(e) {
			console.log("Resizing");
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
			
			for (let setting in settingTypes) {
				let val = clik.parseCssVar($element,setting,settingTypes[setting]);
				if (val != undefined)  {
					if (setting == "animate") {
						if (val != "width" && val != "height" ) {
							val = "none";
						}
					}
					plugin.settings[setting] = val;
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