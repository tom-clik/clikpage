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
			name : "grid-mode",//list | array of vars to apply e.g. ["mode","orienatation"]
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
			console.log(varList);
			for (let name of varList) {
				$element.removeClassByPrefix(name + "-");
				let val =  $element.css("--" + name);
				if (val) {
					$element.addClass(name + "-" + val);
				}
			}
		}

		plugin.addToClasses = function(names) {
			let nameList = names.split(",");
			for (let name of nameList) {
				if (! varList.includes(name)) {
					varList.push(name);
				}
			}
			plugin.reload();
		}

		plugin.init();

	}

	$.fn.varClass = function(options) {

		return this.each(function() {
			
			var temp = $(this).data('varClass');
			
			if (undefined == temp) {

				var plugin = new $.varClass(this, options);

				$(this).data('varClass', plugin);

			}
			else {
				temp.addToClasses(options.name);
			}

		});

	}

})(jQuery);