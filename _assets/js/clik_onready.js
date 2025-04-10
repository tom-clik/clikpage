// on ready to include in all pages
$(document).ready(function() {
	clik.clikContainers();
	clik.clikContent();
});

clik = {
	// deprecated - should now use container css mechanism
	clikContainers: function () {
		$(".inner").parent().addClass("container");
	},
	clikContent: function () {

		resizeMethod = jQuery().throttledresize ? 'throttledresize' : 'resize';

		if(jQuery().autoButton) {
			$('.button.auto').autoButton();
		}

		if(jQuery().modal) {
			const menuAnimationTime = 500;
			const optionTypes = {
				"draggable": "boolean",
				"modal": "boolean",
				"modalAnimationTime": "integer",
				"closebutton" : "string"
			};
			// Need to iterate to apply the callback functions
			$('.modal,.pulldown').each(function( index ) {
				let $modal = $(this);
				let isModal = !$modal.hasClass('pulldown');

				let options = {};

				for (let option in optionTypes) {
					let val = $modal.css("--" + option);
					if (val) {
						options[option] = parseCssVar(val,optionTypes[option]);
					}
				}

				if ("modalAnimationTime" in options) {
					options.onOpen =  function() {
						$modal.css({"visibility": "visible"});
						$modal.animateAuto("height", options.modalAnimationTime, function() {
							console.log("Animation complete");
							$(this).css({"height":"auto"});
						});
					};
					options.onClose = function() {
						$modal.animate({"height":0}, options.modalAnimationTime, function() {
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

		if(jQuery().tabs) {
			$(".cs-tabs").tabs({"resize":"throttledresize","fit":true,"fixedheight":false,"allowClosed":false});
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

		if(jQuery().flickity) {
			$('.list').each(function( index ) {
				$list = $(this);
				var settings = getSettings($list,"articlelist");
				console.log(settings);
				if (settings.carousel) {
					$list.flickity({
				  	  contain: settings["carousel-contain"], 
				  	  freeScroll: settings["carousel-freeScroll"],
				  	  wrapAround:settings["carousel-wrapAround"] 
					});
				}
			});
		}
		
	},

	trueFalse: function(value) {
		switch (value) {
			case "true":
				return true;
			case "false":
				return false;

		}

		return (parseInt(value) && true);
	},
	htmlEscape: function(str) {
	    return str
	        .replace(/&/g, '&amp')
	        .replace(/'/g, '&apos')
	        .replace(/"/g, '&quot')
	        .replace(/>/g, '&gt')   
	        .replace(/</g, '&lt');    
	},

	getImages: function( dataset ) {
		if (typeof site == undefined || ! "data" in site || ! "images" in site.data ) {
			console.log("images not defined");
			return [];
		}
		var data = [];
		for (let image of dataset) {
			if (image in site.data.images);
			data.push(site.data.images[image]);
		}
		return data;
	}
};