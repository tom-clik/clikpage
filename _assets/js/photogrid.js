/*

Clik wrapper for all photogrid functions. Gets the layout type
and then calls carousel or masonry if required.
*/
(function($) {

    $.photoGrid = function(element, options) {

      var plugin = this;
      var defaults = {
        dataset: []
      };
      plugin.settings = {};
      plugin.options = $.extend({}, defaults, options);
      
      var $element = $(element), 
          element = element, 
          id = $element.attr("id"),
          $grid,
          $carousel,
          $popup,
          layout='grid';

      plugin.init = function(options) {
        
        plugin.reload();

        // Editing reload function
        $(window).on("clik.reload",function() {
          console.log("Window reload trigger");
          plugin.reload();
        });
      
      }

      plugin.reload = function() {

        plugin.settings = getSettings($element, "imagegrid");
        console.log(plugin.settings);
        
        // remove any existing plug ins
        if (layout == "masonry") {
            $element.removeClass("masonry");
            $grid.isotope('destroy');
        }
        else if (layout == "carousel") {
            $grid.flickity('destroy');
        }
        else if (layout == "justifiedGallery") {
            $element.removeClass("justifiedGallery");
            $grid.justifiedGallery('destroy');
        }

        layout = plugin.settings.layout;
                
        if (plugin.settings.layout == "masonry") {
          console.log("Applying masonry",plugin.settings);
          $element.addClass("masonry");
          $grid = $element.isotope({
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
          $grid = $element.flickity({
              contain: plugin.settings.contain,
              freeScroll: plugin.settings.freeScroll,
              wrapAround: plugin.settings.wrapAround,
              pageDots: plugin.settings.pageDots,
              prevNextButtons: plugin.settings.prevNextButtons
            }).on( 'change.flickity', function( event, index ) {
             console.log( 'Slide changed to ' + index );
             var cellElements = $element.flickity('getCellElements')
           }).on( 'staticClick.flickity', function( event, pointer,cellElement, cellIndex ) {
             // dismiss if cell was not clicked
             if ( !cellElement ) {
               return;
             }
             $element.flickity("select", cellIndex,true);
           });
        
        } else if (plugin.settings.layout == "justifiedGallery") {
          console.log("Applying justifiedGallery",plugin.settings);
          let jgSettings = {
            imgSelector:".image > img",
            selector: "a"
          };
          if ("grid-max-height" in plugin.settings) {
            jgSettings.rowHeight = plugin.settings["grid-max-height"];
          }
           if ("grid-gap" in plugin.settings) {
            jgSettings.margins = plugin.settings["grid-gap"];
          }
          
          $grid = $element.justifiedGallery(jgSettings);
        
        }
        
        if ( plugin.settings.popup )  {
          $('#' + id + '_popUp').popup({
            imagepath : '',
            data: clik.getImages(plugin.options.dataset),
          });
          $popup = $('#' + id + '_popUp').data('popup');
          let count = 0;
          $('#' + id + ' a').each(function() {
            $(this).data('index', count++);
          })
          $('#' + id + ' > a').on('click',function(e) {
            e.preventDefault();
            e.stopPropagation();
            $popup.goTo($(this).data('index'));
            $popup.open();
          });
          
        }
        
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