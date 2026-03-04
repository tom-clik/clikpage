(function ($) {

  $.fn.shrinkHeaderOnScroll = function (options) {

    // Default settings
    const settings = $.extend({
      threshold: 20,          // scroll distance before activating
      scrolledClass: "solid"  // class added when threshold reached
    }, options);

    return this.each(function () {

      const $header = $(this);

      function updateHeader() {
        if ($(window).scrollTop() > settings.threshold) {
          $header.addClass(settings.scrolledClass);
        } else {
          $header.removeClass(settings.scrolledClass);
        }
      }

      // Run once on page load
      updateHeader();

      // Bind scroll handler
      $(window).on("scroll", updateHeader);

    });

  };

})(jQuery);