/*

# Tabs function

Fancy new semantic markup based tabs system. Place as many items as you like next to each other
and call this on the container. No need for separate header div

## Synopsis

Works by positioning the tab content absolutely. On seleting a tab, has to work out the height of the tab and expand the container. Other than that it's all CSS.

## Usage

```html
<div class="cs-tabs">
	<div class="tab state_open" id="test1" title="Test 1">

		<h3 class="title"><a href="#test1">tab 1</a></h3>

		<div class="item>
			
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

$.fn.tabs = function(ops) {
 	
 	var defaults = {
			vertical: false, // tab hedings in vertical list
			accordian: false, // use accordion mode (vertical ignored)
			resize: "resize", // window event to trigger resize. use e.g. throttledresize
			fixedheight:true,// height is always maximum size
			fitheight:true,
			menuAnimationTime: 600,
			allowClosed: true // all tabs can close in accordion
		},
		options = $.extend({},defaults,ops);

	return this.each(function() {

    	var $tabs = $(this);
    	var vertical = options.vertical || $tabs.hasClass("vertical");
    	var accordian = options.accordian || $tabs.hasClass("accordian");
    	
    	$tabs.on("resize",function() {
    		console.log("Resizing ", $tabs.attr("id"));
    		$tab = $tabs.find(".state_open").first();
    		setHeight($tab);
    	});

    	$(window).on(options.resize, function( event ) {
    		$tabs.trigger("resize");
    	});

    	function setHeight($tab) {
    		if (accordian) return;
    		let t_height = vertical ? 0 : $tabs.outerHeight(); // add height of tab panel if horizontal
    		console.log("tab panel height: " + t_height);
    		if (options.fitheight) {
    			$parent = $tabs.parent();
    			console.log($parent.height());
    			$tab.find(".item").outerHeight($parent.height() - t_height);
    		}
    		else {
    			$tabs.css({"height":"auto"});
    			var maxheight = 0;
	    		if (options.fixedheight) {
		    		$tabs.find(".item").each(function() {
		    			let height = $(this).outerHeight();
		    			if (height > maxheight) maxheight = height;
		    		});
	    		}
	    		else {
	    			// adjust height to selected item
	    			let $item = $tab.find(".item").first();
	    			maxheight = $item.outerHeight();
	    		}
	    		t_height += maxheight;
	    		    		
	    		// make sure height is enough to accomadate vertical tab panel
	    		if (vertical && ( t_height < $tabs.outerHeight() ) ) { 
	    			t_height = $tabs.outerHeight();
	    		}
	    		$tabs.outerHeight(t_height);
	    	}
    	}

    	$tabs.on("click",".title",function() {	
			console.log( "clicked " + $(this).html() );
			let $tab = $(this).parent();

			if ($tab) {
				console.log("opening " + $tab.attr("id"));
				
				if (accordian){
					let open = $tab.hasClass("state_open");
					if (open && ! options.allowClosed) {
						console.log("Can't close: not allowed");	
						return;
					}
					let $closeElements = $tab;
					if (!open) {
						$closeElements = $tab.siblings(".state_open");
						$tab.addClass("state_open").animateAuto("height", options.menuAnimationTime, function() {
							console.log("Animation complete");	
							$tab.css({"height":""}).addClass("state_open");
						});
					}

					$closeElements.animate({"height":0}, options.menuAnimationTime, function() {
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
	})
}