/*

# Tabs function

Fancy new semantic markup based tabs system. Place as many items as you like next to each other
and call this on the container. No need for separate header div

## Synopsis

Works by positioning the tab content absolutely. On seleting a tab, has to work out the height of the tab and expand the container. Other than that it's all CSS.

## Usage

```html
<div class="cs-tabs">
	<div [class="state_open"] id="test1" title="Test 1">

		<h3><a href="#test1">tab 1</a></h3>

		<div>
			
				<p>Tab 1Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
				tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
				quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
				consequat. </p>
					
			
		</div>
	
	</div>
	...rinse and repeat
</div>
```

## Details

@author Tom Peer
@version 1.0

*/

(function($) {

	$.tabs = function(element, options) {

		// plugin's default options
		// this is private property and is accessible only from inside the plugin
		var defaults = {

			vertical: false, // tab headings in vertical list
			accordian: false, // use accordion mode (vertical ignored)
			resize: "resize", // window event to trigger resize. use e.g. throttledresize
			fixedheight:true,// height is always maximum size
			fitheight:false,// fit to element height 
			menuAnimationTime: 200,
			allowClosed: true // all tabs can close in accordion
			
		}

		var settingTypes = {
			vertical: "boolean",
			accordian: "boolean",
			fixedheight: "boolean",
			fitheight: "boolean",
			menuAnimationTime: "integer",
			allowClosed: "boolean"
		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), // reference to the jQuery version of DOM element
			element = element; // reference to the actual DOM element

		plugin.init = function() {

			console.log("Tabs init");
			
			plugin.settings = $.extend({}, defaults, options);
			
			$element.children().addClass("tab");
			$element.children().each(function() {
				let $tabItems = $(this).children();
				$($tabItems[0]).addClass("title");
				$($tabItems[1]).addClass("item");
			});

			console.log(plugin.settings);
			getCssSettings();
			console.log(plugin.settings);

			// can manually set a tab to open by applying class
			$open = $element.find(".state_open");
			
			if (! $open.length) {
				$open = $element.find(".tab").first().addClass("state_open");
			}
			
			setHeight($open);

			$element.on("click",".title",function() {	
				
				console.log( "clicked " + $(this).html() );

				let $tab = $(this).parent();

				if ($tab) {

					console.log("opening " + $tab.attr("id"));
					
					if (plugin.settings.accordian){
						console.log(plugin.settings.menuAnimationTime);
						let open = $tab.hasClass("state_open");
						if (open && ! plugin.settings.allowClosed) {
							console.log("Can't close: not allowed");	
							return;
						}
						
						let $closeElements = $tab;

						if (!open) {
							$closeElements = $tab.siblings(".state_open");
							$tab.addClass("state_open").animateAuto("height", plugin.settings.menuAnimationTime, function() {
								console.log("Animation complete");	
								$tab.css({"height":"auto"}).addClass("state_open");
							});
						}

						$closeElements.animate({"height":0}, plugin.settings.menuAnimationTime, function() {
							console.log("Close Animation complete:", $(this).attr("id"));	
							$(this).removeClass("state_open").css({"height":""});
						});
		
					}
					else {
						if ($tab.hasClass("state_open")) {
							return;
						}
						$tab.addClass("state_open").siblings().removeClass("state_open");
					}
					setHeight($tab);
				}
				// debug
				else {
					console.log("No target found for tab link");
				}
				// /debug
				
			});

			$(window).on(plugin.settings.resize,function() {
				$element.trigger("resize");
			});

		}

		$element.on("resize",function(e) {
			e.stopPropagation();
			getCssSettings();
			let $tab = $element.find(".state_open").first();
			setHeight($tab);
		});
		
		// public methods
		plugin.public_method = function() {
			private_method(plugin.settings.message);
			plugin.settings.onPublic_method();
		}

		// private methods
		var setHeight = function($tab) {
    		console.log("Setting height for ", $tab.attr("id"));
    		if (plugin.settings.accordian) return;
    		
    		let tabs_height = 0;
    		
    		if (! plugin.settings.vertical) {
    			$element.find(".title").each(function() {
    				console.log($(this).html(), $(this).outerHeight());
	    			let height = $(this).outerHeight();
	    			if (height > tabs_height) tabs_height = height;
	    		});
    		}
    		console.log("tabs_height ", tabs_height);

    		if (plugin.settings.fitheight) {
    			console.log("fitheight");
    			let $parent = $element.parent();
    			let panel_height = $parent.height() - tabs_height;
    			element.find(".item").outerHeight(panel_height);
    		}
    		else {
    			$element.css({"height":"auto"});
    			var maxheight = 0;
	    		if (plugin.settings.fixedheight) {
		    		$element.find(".item").each(function() {
		    			let height = $(this).outerHeight();
		    			if (height > maxheight) maxheight = height;
		    		});
		    		$element.find(".item").outerHeight(maxheight);
		    		console.log("max heights: " + maxheight);
	    		}
	    		else {
	    			// adjust height to selected item
	    			let $item = $tab.find(".item").first();
	    			maxheight = $item.outerHeight();
	    			console.log("height of item is ",maxheight);
	    		}
	    		
	    		let total_height = maxheight + tabs_height;

	    		// make sure height is enough to accomadate vertical tab panel
	    		if (plugin.settings.vertical && ( total_height < $element.outerHeight() ) ) { 
	    			total_height = $element.outerHeight();
	    		}
	    		console.log("Setting total_height for ", total_height);

	    		$element.outerHeight(total_height);
	    	}
    	}

    	var getCssSettings = function() {
			
			for (let setting in settingTypes) {
				let val = clik.parseCssVar($element,setting,settingTypes[setting]);
				
				if (val != null) plugin.settings[setting] = val;
			}

			if (plugin.settings.vertical) {
				$element.addClass("vertical");
			}
			else {
				$element.removeClass("vertical");
			}

			if (plugin.settings.accordian) {
				$element.addClass("accordian");
				$element.find(".item").css({height:""});
			}
			else {
				$element.removeClass("accordian");
			}

		}
		
		plugin.init();

	}

	$.fn.tabs = function(options) {

		return this.each(function() {

			if (undefined == $(this).data('tabs')) {

				var plugin = new $.tabs(this, options);

				$(this).data('tabs', plugin);

			}

		});

	}

})(jQuery);