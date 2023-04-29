/*
Fix a div in place when the page is scrolled

## Synopsis

When attached to an element, will convert its position to fixed when it gets to the top of the page.

Will also add a class of "scroll" to the body so styling can be amended e.g. shrinking elements.

## Usage

$("#topnav").scrollFix();

*/ 

(function($) {

	$.scrollFix = function(element, options) {

		var defaults = {
			resize: "resize", // window event to trigger resize. use e.g. throttledresize
			onFix: function() {},
			onUnfix: function() {}
		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), 
			element = element,
			$parent = $element.parent(),
			width,
			offset,
			$body,
			isScroll = false; 

		plugin.init = function() {
			plugin.settings = $.extend({}, defaults, options);
			offset = $element.offset();
			width = $parent.width();
			$body = $('body');  
			isScroll = false;
			

			$(window).on("scroll.scrollFix", function () {  
				var scrollTop = $(window).scrollTop(); // check the visible top of the browser  
				if (offset.top < scrollTop) {
					isScroll = true;
					$body.addClass('scroll');
					$element.css("width",width + "px");
					plugin.settings.onFix();
				}
				else {
					$body.removeClass('scroll'); 
					$element.css("width","auto");
					isScroll = false;
					plugin.settings.onUnfix();
				}
			}).on(plugin.settings.resize,function() {
				console.log("resize");
				width = $parent.width();
				if (isScroll) {
					$element.css("width",width + "px");
				}
			});
		}

		plugin.init();

	}

	$.fn.scrollFix = function(options) {

		return this.each(function() {

			if (undefined == $(this).data('scrollFix')) {

				var plugin = new $.scrollFix(this, options);

			$(this).data('scrollFix', plugin);

			}

		});

	}

})(jQuery);