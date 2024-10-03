
(function($) {

	$.modeClass = function(element, options) {

	var defaults = {

		resize: 'resize'		

	}
	
	var plugin = this;

	plugin.settings = {}

	var $element = $(element);

	plugin.init = function() {

		plugin.settings = $.extend({}, defaults, options);
		
		resize();

		$(window).on(plugin.settings.resize,function() {
			resize();
		});
	}

	var resize = function() {
		
		let mode =  $element.css("--mode") || "none";
		
		$element.removeClassByPrefix("mode-").addClass("mode-" + mode);
		
	}

	plugin.init();

	}

	$.fn.modeClass = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('modeClass')) {

			  var plugin = new $.modeClass(this, options);

			  $(this).data('modeClass', plugin);

		   }

		});

	}

})(jQuery);