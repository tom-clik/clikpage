/*

Clik wrapper for all photogrid functions. Gets the layout type
and then calls carousel or masonry if required.
*/
(function($) {

    $.photoGrid = function(element, options) {

      var plugin = this;

      plugin.settings = {};

      var $element = $(element), 
          element = element, 
          id = $element.attr("id"),
          $grid,
          $carousel,
          layout='grid';

      plugin.init = function() {

        plugin.reload();

        // code goes here

      }

      plugin.reload = function() {

        plugin.settings = getSettings($element, "imagegrid");
        console.log(plugin.settings);
        
        // remove any existing plug ins
        if (layout == "masonry") {
            $grid.isotope('destroy');
        }
        else if (layout == "carousel") {
            $carousel.flickity('destroy');
        }
        layout = plugin.settings.layout;
                
        if (plugin.settings.layout == "masonry") {
          $grid = $('#' + id).isotope({
            layoutMode: 'masonry',
            itemSelector: '.frame',
            masonry: {
              columnWidth: '#' + id + ' .frame',
              gutter: parseInt(plugin.settings["grid-gap"])
            }
          });
          /* layout Masonry after images loaded */
          $grid.imagesLoaded( function() {
            $grid.isotope();
          });
        }
        else if (plugin.settings.layout == "carousel") {
          console.log("Applying carousel",plugin.settings);
          $carousel = $('#' + id);
          $carousel.flickity({
              contain: 1, //plugin.settings.contain,
              freeScroll: 1, //plugin.settings.freeScroll,
              wrapAround: 1, //plugin.settings.wrapAround,
              pageDots: 1, //plugin.settings.pageDots,
              prevNextButtons: 1 //plugin.settings.prevNextButton
            }).on( 'change.flickity', function( event, index ) {
             console.log( 'Slide changed to ' + index );
             var cellElements = $carousel.flickity('getCellElements')
           }).on( 'staticClick.flickity', function( event, pointer,cellElement, cellIndex ) {
             // dismiss if cell was not clicked
             if ( !cellElement ) {
               return;
             }
             $carousel.flickity("select", cellIndex,true);
           });
        
        }
        // MUSTDO: popups -- see original JS in imagegrid.cfc
      }

      plugin.init();


    }

     // add the plugin to the jQuery.fn object
     $.fn.photoGrid = function(options) {

        return this.each(function() {

          if (undefined == $(this).data('photoGrid')) {

              var plugin = new $.photoGrid(this, options);

              $(this).data('photoGrid', plugin);

           }

        });

    }

})(jQuery);