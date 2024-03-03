(function($) {

	$.modal = function(element, options) {

		var defaults = {
			modal: true,
			draggable: false,
			dragTarget: "h2",
			close_icon: "<i class='icon-close'></i>",
			position:"",
			position_at:"",
			position_of:"",
			onOpen: function() {},
			onClose: function() {},
			onOk: function() {},
			onCancel: function() {}
		}

		var settingTypes = {
			modal: "boolean",
			close_icon: "string",
			draggable: "boolean",
			dragTarget: "string",
			position:"string",
			position_at:"string",
			position_of:"string"
		}

		var backdropSettings = {position:'fixed',width:'100vw',height:'100vh',top:0,left:0,'z-index': 999};

		var plugin = this;
		var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

		plugin.settings = {};

		var $element = $(element),
					   element = element; 
					   
		plugin.init = function() {
			plugin.settings = $.extend({}, defaults, options);
			getCssSettings();
			console.log(plugin.settings);
			if (plugin.settings.draggable) {
				$element.on("mousedown",plugin.settings.dragTarget,function() {
					dragMouseDown();
				});
			}

			if (plugin.settings.position != "") {
				plugin.settings.position_of = plugin.settings.position_of.replace("element.id", $element.attr("id"));
				$element.position({
					my: plugin.settings.position,
					at: plugin.settings.position_at,
					of: "#pulldown_pulldown"
				});
			}
			
			$element.addClass("modal").wrapInner("<div class='inner'></div>");
			var $wrapper = $element.find(".inner");
			if (plugin.settings.close_icon != "") {
				let id = $element.attr("id") || "";
				var $closebutton = $(`<div id="${id}_closebutton" class="closebutton button">
					<a href="#popup.cancel">
					${plugin.settings.close_icon}
					<label>Close</label>
					</a>				
				</div>`).appendTo($wrapper);
				
				$closebutton.on("click",`a`, function() {
					$element.trigger("close");
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
			plugin.ok();
		});

		$element.on("cancel",function() {
			plugin.cancel();
		});

		// public methods
		plugin.open = function() {
			var cssSettings = {'z-index': (plugin.settings.modal ? 1000 : 998)};
			console.log("Adding class open");
			$element.css(cssSettings).addClass("open");
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
			$element.removeClass("open");
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
			// calculate the new cursor position:
			plugin.pos1 = plugin.pos3 - e.clientX;
			plugin.pos2 = plugin.pos4 - e.clientY;
			plugin.pos3 = e.clientX;
			plugin.pos4 = e.clientY;
			// set the element's new position:
			let top = element.offsetTop - plugin.pos2;
			let left = element.offsetLeft - plugin.pos1;
			// TODO: restrict. Need to cope with translate styling 
			// on modal popups. Don't use translate on draggable
			// Then we can just restrict to window
			element.style.top = top + "px";
			element.style.left = left + "px";
		}

		var closeDragElement = function() {
			/* stop moving when mouse button is released:*/
			document.onmouseup = null;
			document.onmousemove = null;
		}

		var getCssSettings = function() {
			
			for (let setting in settingTypes) {
				let val = clik.parseCssVar($element,setting,settingTypes[setting]);
				
				if (val != null) plugin.settings[setting] = val;
			}

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