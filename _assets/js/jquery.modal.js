(function($) {

	$.modal = function(element, options) {

		var defaults = {
			modal: true,
			draggable: false,
			dragTarget: "h2",
			closebutton: "<svg class=\"icon\"  viewBox=\"0 0 357 357\"><use xlink:href=\"/_assets/images/close47.svg#close\"></svg>",
			onOpen: function() {},
			onClose: function() {},
			onOk: function() {},
			onCancel: function() {}
		}

		var backdropSettings = {position:'fixed',width:'100vw',height:'100vh',top:0,left:0,'z-index': 999};

		var plugin = this;
		var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

		plugin.settings = {};

		var $element = $(element),
					   element = element; 
					   
		plugin.init = function() {
			plugin.settings = $.extend({}, defaults, options);
			console.log(plugin.settings);
			if (plugin.settings.draggable) {
				console.log("Draggable");
				$element.on("mousedown",plugin.settings.dragTarget,function() {
					dragMouseDown();
				});
			}
		}

		$element.on("open",function() {
			plugin.open();
		});

		$element.on("close",function() {
			plugin.close();
		});

		$element.on("ok",function() {
			console.log("ok handler");
			plugin.ok();
		});

		$element.on("cancel",function() {
			console.log("cancel handler");
			plugin.cancel();
		});

		// public methods
		plugin.open = function() {
			$element.css({"display":"block",'z-index': (plugin.settings.modal ? 1000 : 998)});
			if (plugin.settings.modal) {
				backdrop = $("<div class='backdrop'></div>").appendTo("body")
				.css(backdropSettings)
				.on("mousedown.modal",function(e) {
					e.preventDefault();
					e.stopPropagation();
					plugin.close();	
					
				});
				$(window).on("keydown.modal", function( e ) {
					switch (e.key) {
						case "Escape":
						e.preventDefault();
						plugin.cancel();
						break;
					}	  	 	
				});
			}

			// don't close if we click on the modal
			$element.on("mousedown.modal", function(e) {
				e.stopPropagation();
			});
			
			plugin.settings.onOpen();
		}

		plugin.close = function() {
			$element.css({"display":"none"});
			if (plugin.settings.modal) {
				backdrop.remove();
			}
			$(window).off("keydown.modal");
			plugin.settings.onClose();
		}

		plugin.ok = function() {
			plugin.close();
			plugin.settings.onOk();
		}

		plugin.cancel = function() {
			plugin.close();
			plugin.settings.onCancel();
		}

		var dragMouseDown = function(e) {
			console.log("Mouse down");
			e = e || window.event;
			e.preventDefault();
			// get the mouse cursor position at startup:
			plugin.pos3 = e.clientX;
			plugin.pos4 = e.clientY;
			document.onmouseup = closeDragElement;
			// call a function whenever the cursor moves:
			document.onmousemove = elementDrag;
		}

		var elementDrag = function(e) {
			e = e || window.event;
			e.preventDefault();
			console.log("Dragging");
			// calculate the new cursor position:
			plugin.pos1 = plugin.pos3 - e.clientX;
			plugin.pos2 = plugin.pos4 - e.clientY;
			plugin.pos3 = e.clientX;
			plugin.pos4 = e.clientY;
			// set the element's new position:
			element.style.top = (element.offsetTop - plugin.pos2) + "px";
			element.style.left = (element.offsetLeft - plugin.pos1) + "px";
		}

		var closeDragElement = function() {
			/* stop moving when mouse button is released:*/
			document.onmouseup = null;
			document.onmousemove = null;
		}

		plugin.init();

	}

	$.fn.modal = function(options) {

		return this.each(function() {

			if (undefined == $(this).data('modal')) {

				var plugin = new $.modal(this, options);

				$(this).data('modal', plugin);

			}

		});

	}

})(jQuery);