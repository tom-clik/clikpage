/* 

Apply masonry to any grids with grid-mode=masonry

*/
(function($) {

	$.masonryGrid = function(element, options) {

		var defaults = {

			resize: 'resize'		

		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), 
			element = element,
			$grid =$element.find(".gridInner"),
			$imagegridGrid,
			mode = 'noinit';

		plugin.init = function() {

			plugin.settings = $.extend({}, defaults, options);
			
			resize();

			$(window).on(plugin.settings.resize,function() {
				resize();
			});
		}

		var resize = function() {
			const newmode = $element.css("--grid-mode")  || "none";
			
			if (newmode == "masonry" &&  mode != "masonry" ) {
				$imagegridGrid = $grid.masonry( {
					percentPosition: true,
				} );
				
				$imagegridGrid.imagesLoaded().progress( function() {
					$imagegridGrid.masonry('layout');
					$imagegridGrid.addClass('is-laidout');
				} );
			}
			else if (newmode != "masonry" && mode == "masonry") {
				$imagegridGrid.masonry('destroy');  
			}
			mode = newmode;
			
		}

		plugin.init();

	}

	$.fn.masonryGrid = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('masonryGrid')) {

			  var plugin = new $.masonryGrid(this, options);

			  $(this).data('masonryGrid', plugin);

		   }

		});

	}

})(jQuery);