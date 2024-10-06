/**
 * Apply a class to an html element according to a css variable
 * 
 * ## Synopsis
 *
 * The value of a give variable will be obtained from the CSS and applied as class {varname}-{varvalue}
 *
 * E.g.
 *
 * .cs-grid {
 * 	 --mode:fit;
 * }
 *
 * will add class 'mode-fit'
 * 
 */
(function($) {

	$.varClass = function(element, options) {

	var defaults = {
		name : "mode",// list of vars to apply e.g. "mode,orienatation"
		resize: 'resize'
	}
	
	var plugin = this;

	plugin.settings = {}

	var $element = $(element);

	var varList = []; // contains array of variable names to apply  = defaults.name.split();

	plugin.init = function() {

		plugin.settings = $.extend({}, defaults, options);
		
		varList = plugin.settings.name.split(",");

		plugin.reload();

		$(window).on(plugin.settings.resize,function() {
			plugin.reload();
		});
	}

	plugin.reload = function() {
		
		for (let name of varList) {
			$element.removeClassByPrefix(name + "-");
			let val =  $element.css("--" + name);
			if (val) {
				$element.addClass(name + "-" + val);
			}
		}
	}

	plugin.init();

	}

	$.fn.varClass = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('varClass')) {

			  var plugin = new $.varClass(this, options);

			  $(this).data('varClass', plugin);

		   }

		});

	}

})(jQuery);