// jQuery Plugin Boilerplate
// A boilerplate for jumpstarting jQuery plugins development
// version 1.1, May 14th, 2011
// by Stefan Gabos
// This version modified by Tom Peer

// remember to change every instance of "pluginName" to the name of your plugin!
(function($) {

	// here we go!
	$.pluginName = function(element, options) {

		// plugin's default options
		// this is private property and is accessible only from inside the plugin
		var defaults = {

			message: 'Default message',
			// Window method for resize. Change to throttledresize or your
			// chosen debounce method
			resize: 'resize',
			// if your plugin is event-driven, you may provide callback capabilities
			// for its events. execute these functions before or after events of your
			// plugin, so that users may customize those particular events without
			// changing the plugin's code
			onFoo: function() {},
			onPublic_method: function() {}

		}

		// to avoid confusions, use "plugin" to reference the
		// current instance of the object
		var plugin = this;

		// this will hold the merged default, and user-provided options
		// plugin's properties will be available through this object like:
		// plugin.settings.propertyName from inside the plugin or
		// element.data('pluginName').settings.propertyName from outside the plugin,
		// where "element" is the element the plugin is attached to;
		plugin.settings = {};

		var $element = $(element), // reference to the jQuery version of DOM element
			element = element; // reference to the actual DOM element

		// the "constructor" method that gets called when the object is created
		plugin.init = function() {

			// the plugin's final properties are the merged default and
			// user-provided options (if any)
			plugin.settings = $.extend({}, defaults, options);

			// code goes here
			

			// sample resize function
			$(window).on(plugin.settings.resize,function() {
				width = $element.width();
				console.log("width now" + width);
			});
		}
		
		$element.on("Foo",function() {
			plugin.settings.onFoo();
		});
		
		if ( $.isFunction($.fn.swipeDetector) ) {
			$element.swipeDetector(options);
			$element.on("swipeLeft.sd",function() {
				plugin.public_method_left();
			}).on("swipeRight.sd",function() {
				plugin.public_method_right();
			});
		}

		$(window).on("keydown.pluginName", function( event ) {
			switch (event.key) {
				case "Escape":
		  		event.preventDefault();
		  		plugin.public_method_close();
		  		break;
		  		case "ArrowLeft":
		  		event.preventDefault();
		  		plugin.public_method_left();
		  		break;
		  		case "ArrowRight":
		  		event.preventDefault();
		  		plugin.public_method_right();
		  		break;
		  	}	  	 	
		});


		// public methods
		// these methods can be called like:
		// plugin.methodName(arg1, arg2, ... argn) from inside the plugin or
		// element.data('pluginName').publicMethod(arg1, arg2, ... argn) from outside
		// the plugin, where "element" is the element the plugin is attached to;

		// a public method. for demonstration purposes only - remove it!
		plugin.public_method = function() {
			private_method(plugin.settings.message);
			plugin.settings.onPublic_method();
			// code goes here

		}

		plugin.public_method_left = function() {
			private_method("left");
		}

		plugin.public_method_right = function() {
			private_method("right");
		}

		plugin.public_method_close = function() {
			console.log("Close method. Keybindings should no longer work");
			$(window).off("keydown.pluginName");
		}

		// private methods
		// these methods can be called only from inside the plugin like:
		// methodName(arg1, arg2, ... argn)

		// a private method. for demonstration purposes only - remove it!
		var private_method = function(message) {
			$element.html(message);
		}

		// fire up the plugin!
		// call the "constructor" method
		plugin.init();

	}

	// add the plugin to the jQuery.fn object
	$.fn.pluginName = function(options) {

		// iterate through the DOM elements we are attaching the plugin to
		return this.each(function() {

		  // if plugin has not already been attached to the element
		  if (undefined == $(this).data('pluginName')) {

			  // create a new instance of the plugin
			  // pass the DOM element and the user-provided options as arguments
			  var plugin = new $.pluginName(this, options);

			  // in the jQuery version of the element
			  // store a reference to the plugin object
			  // you can later access the plugin and its methods and properties like
			  // element.data('pluginName').publicMethod(arg1, arg2, ... argn) or
			  // element.data('pluginName').settings.propertyName
			  $(this).data('pluginName', plugin);

		   }

		});

	}

})(jQuery);