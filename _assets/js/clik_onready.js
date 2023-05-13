// on ready to include in all pages
$(document).ready(function() {
	resizeMethod = jQuery().throttledresize ? 'throttledresize' : 'resize';

	if(jQuery().button) {
		$('.button.auto').button();
	}

	if(jQuery().modal) {
		// todo: css setting for this
		menuAnimationTime = 500;
		// Need to iterate to apply the callback functions
		$('.modal,.pulldown').each(function( index ) {
			let $modal = $(this);
			let isModal = !$modal.hasClass('pulldown');
			let options = {
				draggable:false,
				modal:isModal
			}
			if ($modal.hasClass('animate')) {
				options.onOpen =  function() {
					$modal.css({"visibility": "visible"});
					$modal.animateAuto("height", menuAnimationTime, function() {
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