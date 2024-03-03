clik = {
	resize: 'resize',
	$body: false,
	clikContainers: function () {
		$(".inner").parent().addClass("container");
	},  
	clikContent: function () {
		clik.$body = $("body");
		clik.getMedia();
		$(window).on(clik.resize,clik.getMedia);
		// clikWidgets can be safely re-run after dynamic content creation
		clik.clikWidgets();

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
					let val = clik.parseCssVar($wrap, val,optionTypes[option]);
					if (val) {
						options[option] = val;
					}
				}
				if (options.scrollbar) {
					$wrap.mCustomScrollbar();
				}
			});
			
		}
	},
	clikWidgets: function () {
		clik.buttons();
		clik.heightFix();
		clik.modals();
		clik.tabs();
		clik.autoopen();
	},
	getMedia: function() {
		var media = clik.parseCssVar(clik.$body, "media");
		clik.$body.removeClass(function (index, className) {
		    return (className.match (/(^|\s)media-\S+/g) || []).join(' ');
		});
		if (media) {
			for (let medium of media.split(",")) {
				clik.$body.addClass("media-" + medium);
			}
		}
	},
	buttons: function() {
		if(jQuery().button) {
			$('.button.auto').button();
		}
	},
	autoopen: function() {
		if(jQuery().autoopen) {
			$('.container,.autoopen').autoopen();
		}
	},
	heightFix: function() {
		if(jQuery().heightFix) {
			$(".cs-image").heightFix(
				{
					resize: clik.resize,
				}
			);
		}
	},
	tabs: function() {
		if(jQuery().tabs) {
			$(".cs-tabs").tabs({"resize":clik.resize});
		}
	},
	modals: function() {
		if(jQuery().modal) {
			const menuAnimationTime = 500;
			// Need to iterate to apply the callback functions
			$('.modal,.pulldown').each(function( index ) {
				let $modal = $(this);
				var options = {};
				console.log($modal.attr("id"));
				// TODO: add as general option then we can drop this each loop
				if ($modal.hasClass('animate')) {
					options.onOpen =  function() {
						$modal.css({"visibility": "visible"});
						$modal.animateAuto("height", menuAnimationTime, function() {
							console.log("Animation complete");
							$(this).css({"height":"auto"});
						});
					};
					options.onClose = function() {
						$modal.addClass("open");
						$modal.animate({"height":0}, menuAnimationTime, function() {
							$modal.removeClass("open");
						});
					}
				}
				$modal.modal(options);
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
	},
	parseCssVar: function($element, setting, type) {
		
		type = type || "string";

		let val = $element.css("--" + setting);
		
		if ( ! val ) return;

		switch (type) {
			case "boolean":
				let bval = parseInt(val);
				if (Number.isNaN(bval)) {
					val = (val.toLowerCase() == "true");
				}
				else {
					// keep consistency on booleans
					val = bval ? true : false;
				}
				break;
			case "integer":
				val = parseInt(val);
				if (Number.isNaN(val)) {
					return;
				}
				break;
			case "numeric":
				val = parseNumber(val);
				if (Number.isNaN(val)) {
					return;
				}
			case "string":
				val = val.replace(/^"|"$/g, '');
		}
		
		return val;
	}
};