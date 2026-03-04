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

$(".button.auto").button();

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

		const defaults = {
			onOpen: function($element) {},
			onClose: function($element) {}
		};

		const plugin = this;
		const $element = $(element);
		const id = $element.attr("id") || Math.random().toString(36).substring(2, 9);
		let keyBindings = {};
		let state = $element.hasClass("state-open") ? "open" : "close";
		let $links;

		plugin.settings = $.extend({}, defaults, options);

		const setState = newstate => { state = newstate; };
		const getState = () => state;

		plugin.init = function() {

			$links = $element.find("a");

			$links.each(function() {
				const $link = $(this);
				const href = $link.attr("href");
				if (!href) return console.warn("No href for button link");

				const parts = href.split(".");
				if (parts.length !== 2) return console.warn(`Invalid button href: ${href}`);

				const targetSelector = parts[0].startsWith("#") ? parts[0] : "#" + parts[0];
				$link.data("target", $(targetSelector));
				$link.data("action", parts[1]);

				const key = $link.data("key");
				if (key) keyBindings[key.toLowerCase()] = $link;
			});

			$element.on("click.autoButton", "a", function(e) {
				e.preventDefault();
				e.stopPropagation();

				const $self = $(this);
				let action = $self.data("action");
				const $target = $self.data("target");
				if (!$target || !action) return console.warn("Invalid autobutton link");

				if (action === "openclose") {
					action = getState() === "open" ? "close" : "open";
					action === "open" ? plugin.open() : plugin.close();
				}
				else {
					var index = $element.data("index");
					if (!index) {
						index = 0;
					}
					index++;
					if (index == $links.length) index = 0; 
					$element.data("index",index);
				}

				$target.trigger(action);

				if ($links.length > 1) {
					$links.css({"display":"none"});
					$($links[index]).css({"display":"flex"});
				}
			});

			$(window).on(`keyup.button-${id}`, function(event) {
				const key = (event.ctrlKey || event.metaKey ? "ctrl+" : "") +
										(event.altKey ? "alt+" : "") +
										event.key.toLowerCase();
				if (key in keyBindings) {
					keyBindings[key].trigger("click");
					event.preventDefault();
					event.stopPropagation();
				}
			});
		};

		plugin.open = function() {
			$element.removeClass("state-close").addClass("state-open");
			setState("open");
			plugin.settings.onOpen($element);
		};

		plugin.close = function() {
			$element.removeClass("state-open").addClass("state-close");
			setState("close");
			plugin.settings.onClose($element);
		};

		plugin.destroy = function() {
			$(window).off(`keyup.button-${id}`);
			$element.off(".autoButton").removeData("autoButton");
		};

		$element.on("open.autoButton", plugin.open);
		$element.on("close.autoButton", plugin.close);

		plugin.init();
	};

	$.fn.autoButton = function(options) {
		return this.each(function() {
			if (!$(this).data("autoButton")) {
				const plugin = new $.autoButton(this, options);
				$(this).data("autoButton", plugin);
			}
		});
	};

})(jQuery);
