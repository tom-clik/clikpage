/**
 * Remove all classes that match a prefix
 *
 * e.g. when applying a mode-fixed class we want to remove all other mode-name classes
 */
$.fn.removeClassByPrefix = function(prefix) {
    this.each(function(i, el) {
        var classes = el.className.split(" ").filter(function(c) {
            return c.lastIndexOf(prefix, 0) !== 0; // Filter out classes that start with the prefix
        });
        el.className = $.trim(classes.join(" ")); // Set the remaining classes
    });
    return this;
};