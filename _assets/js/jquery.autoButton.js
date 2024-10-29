/*

# Auto button function

Convert #id.action urls for button links into an onclick method that triggers the action on the specified target

Shows/hides buttons in the order they appear in the HTML for multiple states.

An open openclose action can be applied to a single button which will toggle the action. In this case the button can have different styling according to the class (.button.state-open). The button is closed by default. Add class="state-open" to change this.

## Details

The method is applied to a button container. This typically will have two elements in it for e.g. open and close. The CSS will only show the first button by default.

In the actual buttons themselves there should be `<a>` tags with a url of the form #target.action.

The target elements should have methods for the actions specified, e.g. on("open",{}).on("close",{});

The action openclose will "toggle" the open and close actions. By default the state is assumed to be "close" to start. Override this with data-state="open" and  class="state-open" on the button.

### Styling

Ensure your styling hides the buttons as required. E.g. 

```CSS
.button > a:not(:first-child) {
    display: none;
}
```

For openclose buttons a class state-<state> is applied. Style your button with
ith e.g. a rotate function for state-open

## Usage

Typically apply to all relevant elements by a standardised class, e.g.

$(".button").button();

Typical actions are open, close (or the special case openclose which can be applied to a single button).

```HTML
<div class="button scheme-hamburger" id="mainmenu_button">
	<a href="#mainmenu.open">
		<svg class="icon" viewBox="0 0 32 32"><use xlink:href="_common/images/menu.svg#menu"></svg>
	</a>
	<a href="#mainmenu.close">
		<svg  class="icon" viewBox="0 0 357 357"><use xlink:href="_common/images/close47.svg#close"></svg>
	</a>
</div>
```

@author Tom Peer
@version 2.0

*/
(function($) {

$.autoButton = function(element, options) {

	var defaults = {

		onOpen: function() {},
		onClose: function() {}

	}

	var plugin = this;

	var $element = $(element), // reference to the jQuery version of DOM element
		element = element, // reference to the actual DOM element
	 	keyBindings = {}, // theoretically we can bind more than one key but this isn't working yet.
	 	state = "close", // for toggle buttons, store the current state
	 	$links;

	// the "constructor" method that gets called when the object is created
	plugin.init = function() {

		// the plugin's final properties are the merged default and
		// user-provided options (if any)
		plugin.settings = $.extend({}, defaults, options);

		// code goes here
		if ($element.hasClass("state-open") ) {
			state = "open"
		}

	    $links = $element.find("a")

		$links.each(function() {
			let $link  = $(this);
			let href = $link.attr("href");

			if (href !== undefined) {
				let attrs = $link.attr("href").split(".");
				
				if (attrs.length == 2) {
					$link.data( "action", attrs[1] );
					$link.data( "target", $(attrs[0]) );
					console.log("Adding autobutton", attrs[0], attrs[1]);
				}
				
				let key = $link.data("key");
				if (key) {
					keyBindings[ String(key).toLowerCase() ] = $link;
				}

			}
			// DEBUG
			else {
				console.log("No href tag found for <a> tag in button");
			}
			// /DEBUG
		});

		$element.on("click","a",function(e) {
	    		
			e.preventDefault();
			e.stopPropagation();

			var $self = $(this);
			let action = $self.data("action");
			let $target = $self.data("target");

			if ($target && action) {
				let index = 0;
		    	if (action == "openclose") {
					
					console.log(`state is ${state}`);

					//changeState(state);
					action = state == "open" ? "close" : "open";
					console.log(action);
					if (action == "open") {
						plugin.open();
					}
					else {
						plugin.close();
					}
				}
				else {
					index = $element.data("index");
					if (!index) {
						index = 0;
					}
					index++;
					if (index == $links.length) index = 0; 
					$element.data("index",index);

				}
				
				console.log("triggering " + action + " on " + $target.attr("id"));
				
				$target.trigger(action);

				if ($links.length > 1) {
					$links.css({"display":"none"});
					$($links[index]).css({"display":"flex"});
				}
			}
			// debug
			else {
				console.log("No auto actions for button");
			}
			// /debug
			
		});

		$(window).on("keyup.button", function( event ) {
			let key = (event.ctrlKey || event.metaKey ? "ctrl+" : "") +  (event.altKey ? "alt+" : "") + event.key.toLowerCase();
			if (key in keyBindings) {
				keyBindings[key].trigger("click"); 
				event.preventDefault();
				event.stopPropagation();
			}
		});
	}

	$element.on("open",function() {
		plugin.open();
	});

	$element.on("close",function() {
		plugin.close();
	});

	plugin.open = function() {
		$element.removeClass("state-close");
		$element.addClass("state-open");
		state = "open";

		plugin.settings.onOpen();

	}
	plugin.close = function() {
		$element.removeClass("state-open");
		$element.addClass("state-close");
		state = "close";

		plugin.settings.onClose();
	
	}

	
	plugin.init();

}

// add the plugin to the jQuery.fn object
$.fn.autoButton = function(options) {

	// iterate through the DOM elements we are attaching the plugin to
	return this.each(function() {

	  // if plugin has not already been attached to the element
	  if (undefined == $(this).data('autoButton')) {

		  // create a new instance of the plugin
		  // pass the DOM element and the user-provided options as arguments
		  var plugin = new $.autoButton(this, options);

		  // in the jQuery version of the element
		  // store a reference to the plugin object
		  // you can later access the plugin and its methods and properties like
		  // element.data('autoButton').publicMethod(arg1, arg2, ... argn) or
		  // element.data('autoButton').settings.propertyName
		  $(this).data('autoButton', plugin);

	   }

	});

}

})(jQuery);