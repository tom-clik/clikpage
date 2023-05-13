
(function($) {

	$.heightFix = function(element, options) {

	var defaults = {

		resize: 'resize'		

	}

	var plugin = this;

	plugin.settings = {}

	var $element = $(element), 
		element = element,
		$container,
		$image,
		paddings; 

	plugin.init = function() {

		plugin.settings = $.extend({}, defaults, options);
		$container = $element.parent();
		$image = $element.find("img");
		paddings = $element.outerHeight(true) - $element.height();
		resize();

		$(window).on(plugin.settings.resize,function() {
			resize();
		});
	}

	var resize = function() {
		let resize =  clik.trueFalse( $image.css("--heightfix") ) || false;
		if (resize) {
			$element.css("height","auto");
			$image.css({"display":"none"});
			let h = $container.height();
			$element.css("height",(h-paddings) + "px");
		}
		else {
			$image.removeAttr("style");
		}
		
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