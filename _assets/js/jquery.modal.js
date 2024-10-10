(function($) {

	$.modal = function(element, options) {

		var defaults = {
			modal: true,
			draggable: false,
			dragTarget: ".title",
			closebutton: "<i class='icon-close'></i>",
			scroll: true, // 
			onOpen: function($element) {},
			onClose: function($element) {},
			onOk: function($element) {},
			onCancel: function($element) {}
		}

		var plugin = this;
		var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

		plugin.settings = {};

		var $element = $(element),
					   element = element,
					   $wrapper,
					   $title,
					   $content;

		var $backdrop;

		plugin.init = function() {
			
			plugin.settings = $.extend({}, defaults, options);
			
			plugin.settings.scroll = jQuery().mCustomScrollbar && plugin.settings.scroll;
			
			let cssSettings = {'z-index': (plugin.settings.modal ? 1000 : 998)};
			
			$element.css(cssSettings)

			$backdrop = $("#backdrop");

			if ( ! $backdrop.length ) {
				$backdrop = $("<div id='backdrop'></div>").appendTo("body");
			}
			
			let html = $element.html();
			
			//  Optional title attribute on DIV
			const title = $element.attr("title");
			
			$element.wrapInner(`<div class='wrapper'><div class='content'></div></div>`);
			
			$wrapper = $element.find(".wrapper");
			$content = $element.find(".content");
			
			if (title) {
				$title = $(`<div class='title'>${title}</div>`).prependTo($wrapper);
				$element.addClass("hasTitle");
			}

			if (plugin.settings.scroll) {
				$content.mCustomScrollbar();
			}
			
			if ( plugin.settings.closebutton !== "none" ) {
				
				$(`<div class="closebutton button auto">
					<a href="#">
						${plugin.settings.closebutton}
						<label>Close Popup</label>
					</a>				
				   </div>`).prependTo($wrapper).on("click",function() { plugin.close(); });
			}
			
			if (plugin.settings.draggable) {
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
			plugin.ok();
		});

		$element.on("cancel",function() {
			plugin.cancel();
		});

		// public methods
		plugin.open = function() {
			

			let titleheight = $title !== undefined ? $title.height() : 0;
			$content.height($wrapper.innerHeight() - titleheight);

			$element.addClass("open");
			
			if (plugin.settings.modal) {
				$backdrop.show();
				$backdrop.on("click",function(e) {
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
			$element.on("click", function(e) {
				e.stopPropagation();
			});
			
			plugin.settings.onOpen($element);
		}

		plugin.close = function() {
			
			$element.removeClass("open");
			
			if (plugin.settings.modal) {
				$backdrop.hide();
				$backdrop.off("mousedown.modal");
			}
			
			$(window).off("keydown.modal");
			plugin.settings.onClose($element);
		}

		plugin.ok = function() {
			console.log("ok");
			plugin.close();
			plugin.settings.onOk($element);
		}

		plugin.cancel = function() {
			plugin.close();
			plugin.settings.onCancel($element);
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