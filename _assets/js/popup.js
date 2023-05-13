 
(function($) {

	$.popup = function(element, options) {

		var defaults = {
			index: 0,
			imagepath: "",
			data:[],// array of image objects
			onNext: function() {},
			onPrevious: function() {},
			onOpen: function() {},
			onClose: function() {},
			onGoTo: function() {}
		}

		var plugin = this;

		plugin.settings = {};
		// Internal array of loaded images
		plugin.images = [];
	
		var $element = $(element),
			element = element; 

		plugin.init = function() {

			plugin.settings = $.extend({}, defaults, options);
			console.log(plugin.settings.data);	
			$inner = $element.find(".popup_inner");
			$inner.html(plugin.html());
			$image = $element.find(".popup_image img");
			
			$caption = $element.find(".popup_caption");

			plugin.goTo(plugin.settings.index);
		
		}

		$element.on("open",function() {
			plugin.open();
		});
		$element.on("close",function() {
			plugin.close();
		});
		$element.on("goTo",function(data) {
			plugin.goTo(data);
		});
		$element.on("next",function() {
			plugin.next();
		});
		$element.on("previous",function() {
			plugin.previous();
		});

		if ( $.isFunction($.fn.swipeDetector) ) {
			$element.swipeDetector(options);
			$element.on("swipeLeft.sd",function() {
				console.log("Swipe left");
				plugin.previous();
			}).on("swipeRight.sd",function() {
				console.log("Swipe right");
				plugin.next();
			});
		}
		else {
			console.warn("No swipe detector defined");
		}

		$(window).on("keydown.popup", function( event ) {
			switch (event.key) {
				case "Escape":
		  		event.preventDefault();
		  		plugin.close();
		  		break;
		  		case "ArrowLeft":
		  		event.preventDefault();
		  		plugin.previous();
		  		break;
		  		case "ArrowRight":
		  		event.preventDefault();
		  		plugin.next();
		  		break;
		  	}	  	 	
		});

		// public methods
		plugin.open = function() {
			$element.css({"display":"block"});
			plugin.settings.onOpen();
		}

		plugin.next = function() {
			if (plugin.settings.index < plugin.settings.data.length - 1) {
				plugin.settings.index++;
			}
			else {
				plugin.settings.index = 0;
			}
			plugin.update();
			plugin.settings.onNext();
		}

		plugin.previous = function() {
			
			if (plugin.settings.index > 0) {
				plugin.settings.index--;
			}
			else {
				plugin.settings.index = plugin.settings.data.length - 1;
			}
			plugin.update();
			plugin.settings.onPrevious();
		}

		plugin.goTo = function(index) {
			if (index <= plugin.settings.data.length && index >= 0) {
				plugin.settings.index = index;
				plugin.update();
				plugin.settings.onGoTo();
			}
			
		}

		plugin.close = function() {
			$element.css({"display":"none"});
			plugin.settings.onClose();
		}

		// update image and caption
		plugin.update = function() {
			
			if (! (plugin.settings.index in plugin.images)) {
				var img_record = plugin.settings.data[plugin.settings.index];
				var img = new Image();
				img.onload = function() {
					plugin.images[plugin.settings.index] = $(this)[0];
					plugin.resize();
				};
				img.src = plugin.settings.imagepath + img_record.image;
			} 
			else {
				plugin.resize();
			}
			
		}
		// This resize function looks at the whole window and then resizes the actual
		// img. This is fine but often it's better to let a grid layout
		// take the strain of calculating the heights and then fixing the height of an element
		plugin.resize = function() {
			var img_record = plugin.settings.data[plugin.settings.index];
			var img = plugin.images[plugin.settings.index];
			$window = $(window);
			var vw = $window.width() - 60;// TODO: padding calcs
			var vh = $window.height() - 60;
			var dw = vw / img.width;
			var dh = vh / img.height;
			
			if (dw < 1.0 || dh < 1.0) {
				if (dw < dh) {
					$image.css('width', vw);
					$image.css('height', "auto");
				}
				else {
					$image.css('height', vh);
					$image.css('width', "auto");
				}
			}

			$image.attr('src',plugin.settings.imagepath + img_record.image);
			$caption.html(img_record.description);
		}

		// render initial html
		plugin.html = function() {
			var img = plugin.settings.data[plugin.settings.index];
			var html = "<div class='popup_image'>";
			html += "	<img src='" + plugin.settings.imagepath + img.image + "'>";
			html += "</div>";
			html += "<div class='popup_caption'>";
			html += img.description;
			html += "</div>";
			return html;
		}

		plugin.init();

	}

	$.fn.popup = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('popup')) {

			  var plugin = new $.popup(this, options);

			  $(this).data('popup', plugin);

		   }

		});

	}

})(jQuery);