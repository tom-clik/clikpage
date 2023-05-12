
(function($) {

	$.heightFix = function(element, options) {

	var defaults = {

		resize: 'resize'		

	}

	var plugin = this;

	plugin.settings = {}

	var $element = $(element), 
		element = element; 

	plugin.init = function() {

		plugin.settings = $.extend({}, defaults, options);
		console.log($element.attr("id"));
		$container = $element.parent();
		console.log($container.attr("id"));
		$image = $element.find("img");
		paddings = $element.outerHeight(true) - $element.height();
		resize();

		$(window).on(plugin.settings.resize,function() {
			resize();
		});
	}

	var resize = function() {
		$image.css({"display":"none"});
		$element.css("height","auto");
		var h = $container.height();
		console.log(h);
		$element.css("height",(h-paddings) + "px");
		$image.css({"display":"block"});
	}

	plugin.init();

	}

	$.fn.heightFix = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('heightFix')) {

			  var plugin = new $.heightFix(this, options);

			  $(this).data('heightFix', plugin);

		   }

		});

	}

})(jQuery);