(function ($) {

    $.fn.fadeInOnScroll = function (options) {

        var settings = $.extend({
            visibleClass: "fade-in-visible",
            baseClass: "fade-in-scroll",
            threshold: 0.15
        }, options);

        var observer = new IntersectionObserver(function (entries, obs) {

            entries.forEach(function (entry) {

                if (entry.isIntersecting) {

                    $(entry.target).addClass(settings.visibleClass);

                    // Only run once
                    obs.unobserve(entry.target);
                }

            });

        }, {
            threshold: settings.threshold
        });

        return this.each(function () {

            var $el = $(this);

            $el.addClass(settings.baseClass);

            observer.observe(this);

        });

    };

})(jQuery);