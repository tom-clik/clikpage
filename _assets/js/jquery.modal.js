(function($) {

	$.modal = function(element, options) {

		const defaults = {
			modal: true,
			draggable: false,
			dragTarget: ".title",
			closebutton: "<i class='icon-close'></i>",
			scroll: true, 
			pulldown: false, // act like pull down menu from data-parent
			positionMy: "right top+1", // relative to data-parent
			positionAt: "right bottom",
			animationTime: 400,
			width: "parent",
			onOpen: function($element) {},
			onClose: function($element) {},
			onOk: function($element) {},
			onCancel: function($element) {}
		};

		const settingTypes = {
			animate: "boolean",
			animationTime: "integer",
			closebutton: "string",
			modal: "boolean",
			draggable: "boolean",
			scroll: "boolean",
			pulldown: "boolean",
			positionMy: "string",
			positionAt: "string",
			width: "string"
		};

		const plugin = this;
		const $element = $(element);
		const id = $element.attr("id") || Math.random().toString(36).substring(2, 9);
		let $wrapper, $title, $content, $backdrop;
		const parent = $element.data("parent");
		
		

		// ---------------------------------------------------------
		// Init
		// ---------------------------------------------------------
		plugin.init = function(options) {

			plugin.settings = $.extend(true, {}, defaults, clik.parseCssVars($element, settingTypes), options);

			plugin.settings.scroll = jQuery().mCustomScrollbar && plugin.settings.scroll;

			const zBase = 1000 + $(".modal.open").length * 2;
			$element.css({'z-index': zBase + 1});

			// Unique backdrop per modal
			if (plugin.settings.modal) {
				$backdrop = $("<div class='modal-backdrop'></div>").appendTo("body")
				.css('z-index', zBase)
				.hide();
			}

			// Structure
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

			if (plugin.settings.closebutton && !plugin.settings.pulldown) {
				const tmp = `
					<div class="closebutton button auto">
					<a href="#">${plugin.settings.closebutton}<label>Close Popup</label></a>
					</div>`;
				$(tmp).prependTo($wrapper).on("click", function(e) {
					e.preventDefault();
					plugin.close();
				});
			}

			// Draggable setup
			if (plugin.settings.draggable) {
				$element.on("mousedown", plugin.settings.dragTarget, function(e) {
					dragMouseDown(e);
				});
			}

			// Events
			$element
			.on("open", plugin.open)
			.on("close", plugin.close)
			.on("ok", plugin.ok)
			.on("cancel", plugin.cancel);
		};

		// ---------------------------------------------------------
		// Public methods
		// ---------------------------------------------------------

		plugin.open = function() {
			console.log("running open method on " + id);
			let titleheight = $title !== undefined ? $title.height() : 0;

			if (!plugin.settings.pulldown) {
				$content.height($wrapper.innerHeight() - titleheight);
				$element.addClass("open");
			}
			else {

				let $parent = $('#' + parent);
				
				$element.addClass("open").css({visibility: "hidden"});

				if ($parent.length) {
					if (plugin.settings.width == "parent") {
						$element.width($parent.outerWidth());
					}
					// content assumed to be a vertical menu in flex mode
					else if (plugin.settings.width == "auto") {
						let $li = $element.find("li").first();
						$element.width($li.outerWidth());
					}
					$element.css({ top: 0, left: 0 }).position({
						my: plugin.settings.positionMy,
						at: plugin.settings.positionAt,
						of: $parent
					});
				}

				$element.css({visibility: "visible"});
				
			}

			// --- Handle pulldown animation ---
			if (plugin.settings.pulldown) {
				// Animation has been found to cuase issues when called on multiple
				// pulldowns. We need a solution to this
				// $element.animateAuto("height", plugin.settings.animationTime, function() {
				// 	$element.css({"height": "auto"});
				// });
				
			}

			// --- Handle backdrop + modal behavior ---
			if (plugin.settings.modal) {

				// Always ensure a backdrop exists
				$backdrop = $("#backdrop");
				if (!$backdrop.length) {
					$backdrop = $("<div id='backdrop'></div>").appendTo("body");
				}

				// Reset any stale event handlers and ensure correct styling
				$backdrop
					.off("click.modal")               // remove any old handlers
					.css({
						display: "block",
						"z-index": 999,
						position: "fixed",
						inset: 0,
						background: "rgba(0, 0, 0, 0.5)"
					})
					.on("click.modal", function(e) {
						e.preventDefault();
						e.stopPropagation();
						plugin.close();
					});
				
			}

			// Attach ESC key handler
			$(window)
				.off("keydown.modal")
				.on("keydown.modal", function(e) {
					if (e.key === "Escape") {
						e.preventDefault();
						plugin.cancel();
					}
				});

			// Prevent modal click from closing it
			if (plugin.settings.modal) {
				$element.on("click.modal", function(e) {
					e.stopPropagation();
				});
			}	

			plugin.settings.onOpen($element);
		};


		plugin.close = function() {

			console.log("Running close method " + id);

			if (plugin.settings.modal) {
				$backdrop.hide();
				$backdrop.off("click.modal");
			}

			if (plugin.settings.pulldown) {
				$element.removeClass("open");
				// Animation has been found to cuase issues when called on multiple
				// pulldowns. We need a solution to this
				// $element.animate({"height": 0}, plugin.settings.animationTime, function() {
				// 	$element.removeClass("open");
				// 	$element.css({"height": "auto"});
				// });
			} else {
				$element.removeClass("open");
			}

			$(window).off("keydown.modal");
			$element.off("click.modal");

			if (parent) {
				console.log("Triggering close on " + parent);
				$("#" + parent).trigger("close");
			}
			
			plugin.settings.onClose($element);

		};


		plugin.ok = function() {
			plugin.close();
			plugin.settings.onOk($element);
		};

		plugin.cancel = function() {
			plugin.close();
			plugin.settings.onCancel($element);
		};

		plugin.destroy = function() {
			$(window).off(`keydown.modal-${id}`);
			$(document).off(`mousemove.modalDrag-${id} mouseup.modalDrag-${id}`);
			$element.off(".modal").removeData("modal");
			if ($backdrop) $backdrop.remove();
		};

		// ---------------------------------------------------------
		// Internal helpers
		// ---------------------------------------------------------


		const dragMouseDown = function(e) {
			e.preventDefault();
			let pos3 = e.clientX;
			let pos4 = e.clientY;

			$(document)
			.on(`mouseup.modalDrag-${id}`, closeDragElement)
			.on(`mousemove.modalDrag-${id}`, function(e) {
				e.preventDefault();
				const pos1 = pos3 - e.clientX;
				const pos2 = pos4 - e.clientY;
				pos3 = e.clientX;
				pos4 = e.clientY;
				element.style.top = (element.offsetTop - pos2) + "px";
				element.style.left = (element.offsetLeft - pos1) + "px";
			});
		};

		const closeDragElement = function() {
			$(document).off(`mouseup.modalDrag-${id} mousemove.modalDrag-${id}`);
		};

		// ---------------------------------------------------------
		// Init call
		// ---------------------------------------------------------
		plugin.init(options);
	};

	// jQuery wrapper
	$.fn.modal = function(options) {
		return this.each(function() {
			if ($(this).data('modal') === undefined) {
			const plugin = new $.modal(this, options);
			$(this).data('modal', plugin);
			}
		});
	};

})(jQuery);
