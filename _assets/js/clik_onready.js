// on ready to include in all pages
$(document).ready(function() {
	
	resizeMethod = jQuery().throttledresize ? 'throttledresize' : 'resize';

	if(jQuery().button) {
		$('.button.auto').button();
	}

	if(jQuery().modal) {
		const menuAnimationTime = 500;
		const optionTypes = {
			"draggable": "boolean",
			"modal": "boolean",
			"menuAnimationTime": "integer"
		};
		// Need to iterate to apply the callback functions
		$('.modal,.pulldown').each(function( index ) {
			let $modal = $(this);
			let isModal = !$modal.hasClass('pulldown');

			let options = {
				draggable:false,
				modal:isModal,
				menuAnimationTime: menuAnimationTime
			}
			for (let option in optionTypes) {
				let val = $modal.css("--" + option);
				if (val) {
					options[option] = parseCssVar(val,optionTypes[option]);
				}
			}

			if ($modal.hasClass('animate')) {
				options.onOpen =  function() {
					$modal.css({"visibility": "visible"});
					$modal.animateAuto("height", options/menuAnimationTime, function() {
						console.log("Animation complete");
						$(this).css({"height":"auto"});
					});
				};
				options.onClose = function() {
					$modal.animate({"height":0}, menuAnimationTime, function() {
						$modal.css({"visibility": "hidden"});
					});
				}
			}
			$modal.modal(options);
		});
	}
	if(jQuery().heightFix) {
		$(".cs-image").heightFix(
			{
				resize: resizeMethod,
			}
		);
	}
	
	/**
	 * Attach a custom scrollbar to any element with a class of .wrap
	 * and a setting of --scrollbar:1
	 */
	if(jQuery().mCustomScrollbar) {
		const optionTypes = {
			"scrollbar": "boolean"
		};
		$('.wrap').each(function( index ) {
			let $wrap = $(this);
			let options = {
				scrollbar:false
			}
			for (let option in optionTypes) {
				let val = $wrap.css("--" + option);
				if (val) {
					options[option] = parseCssVar(val,optionTypes[option]);
				}
			}
			console.log(options);
			if (options.scrollbar) {
				$wrap.mCustomScrollbar();
			}
		});
		
	}
});

clik = {
	trueFalse: function(value) {
		switch (value) {
			case "true":
				return true;
			case "false":
				return false;

		}

		return (parseInt(value) && true);
	}

}