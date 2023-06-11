/*

# Auto button function

Convert #id.action urls for button links into an onclick method that triggers the action on the specified target

Shows/hides buttons in the order they appear in the HTML for multiple states.

An open openclose action can be applied to a single button which will toggle the action. In this case the button can have different styling according to the class (.button.state_open)

## Details

The method is applied to a button container. This typically will have two elements in it for e.g. open and close. The CSS will only show the first button by default.

In the actual buttons themselves there should be `<a>` tags with a url of the form #target.action.

The target elements should have methods for the actions specified, e.g. on("open",{}).on("close",{});

The action openclose will "toggle" the open and close actions. By default the state is assumed to be "close" to start. Override this with data-state="open" and  class="state_open" on the button.

### Styling

Ensure your styling hides the buttons as required. E.g. 

```CSS
.button > a:not(:first-child) {
    display: none;
}
```

For openclose buttons a class state_<state> is applied.

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
@version 1.0

*/
(function($) {

	$.fn.button = function() {
	 	
	    return this.each(function() {

	    	var $button = $(this);
	    	 
	    	var $links = $(this).find("a");

	    	let state = $button.data("state");
	    	
	    	$button.find("a").each(function() {
	    		let $link  = $(this);
	    		let href = $link.attr("href");
	    		if (href !== undefined) {
	    			let attrs = $link.attr("href").split(".");
		    		$link.data("action",attrs[1]);
		    		$link.data("target",$(attrs[0]));
		    		console.log("Adding ", attrs[0], attrs[1]);
	    		}
	    		// DEBUG
	    		else {
	    			console.log("No href tag found for <a> tag in button");
	    		}
	    		// /debug
	    	});

	    	$(this).on("click","a",function(e) {

				e.preventDefault();
				e.stopPropagation();

				var $self = $(this);
				let action = $self.data("action");
				let $target = $self.data("target");

				if ($target && action) {
					let index = 0;
			    	if (action == "openclose") {
						let state = $button.data("state");
						if (!state) {
							state = "close";
						}
						action = state == "open" ? "close" : "open";
						$button.removeClass("state_" + state);
						$button.addClass("state_" + action);
						$button.data("state",action);
					}
					else {
						index = $button.data("index");
						if (!index) {
							index = 0;
						}
						index++;
						if (index == $links.length) index = 0; 
						$button.data("index",index);

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
		})
	}
})(jQuery);