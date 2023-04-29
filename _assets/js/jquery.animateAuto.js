/*
# Animate to height: auto

You can't animate to an auto value for height using CSS animations, so we need to
keep using jQuery. The actual jquery.animate also can't do it, so we use this 
simplified replacement.

## Usage

Similar usage as jquery.animate, but takes property as a string, either width, height, or "both"

`
$(this).animateAuto("height", menuAnimationTime, function() {
    $(this).css({"height":"auto"});
});
`

Note it's good practice to reset the height to auto in the callback.

## Notes

Originally this created a clone of the element and then got the height. This didn't
get the correct width. As a quick fix I tried not cloning and it seems to work fine.

It might be that it causes FOUCs and then we will need to revert to cloning and assign
the correct width.
*/

/**
 * 
 * Animate to auto values for height or width
 *
 * @param  {string}    prop     "width", "height", or "both"
 * @param  {numeric}   duration    Duration
 * @param  {Function}  callback [description]
 */
jQuery.fn.animateAuto = function(prop, duration, callback){
    var elem, height, width;
    return this.each(function(i, el){

        let $el = jQuery(el); 
        
        //, elem = el.clone().css({"height":"auto","width":"auto","visibility":"visible"}).appendTo("body");

        $el.css({"height":"auto","width":"auto"});
        height = $el.css("height");
        width = $el.css("width");

        // $elem.remove();
        
        if(prop === "height") {
            $el.css({"height":0});   
            $el.animate({"height":height}, duration, callback);
        }
        else if(prop === "width") {
            $el.css({"width":0}); 
            $el.animate({"width":width}, duration, callback);  
        }
        else if(prop === "both") {
            $el.css({"height":0,"width":0});   
            $el.animate({"width":width,"height":height}, duration, callback);
        }
    });  
}
