(function(){
    "use strict";
    $.Toast = function(title, message, type, options){
        var defaultOptions = {
            appendTo: "body",
            stack: false,
            position_class: "toast-bottom-right",
            fullscreen:false,
            width: 250,
            spacing:20,
            timeout: 4000,
            has_close_btn:true,
            has_icon:true,
            border_radius:6,
            has_progress:false,
            rtl:false
        }

        var $element = null;

        var $options = $.extend(true, {}, defaultOptions, options);

        var css = {
            "position":($options.appendTo == "body") ? "fixed" : "absolute",
            "display":"none",
            "border-radius":$options.border_radius,
            "z-index":99999
        }

        $element = $('<div class="toast-item-wrapper ' + type + ' ' + $options.position_class + '"></div>');
        if (title !== "") {
            $('<p class="toast-title">' + title + '</p>').appendTo($element);
        }
        $('<p class="toast-message">' + message + '</p>').appendTo($element);

        if($options.fullscreen){
            $element.addClass( "fullscreen" );
        }

        if($options.rtl){
            $element.addClass( "rtl" );
        }

        if($options.has_close_btn){
            $('<span class="toast-close">&times;</span>').appendTo($element);
            if( $options.rtl){
                css["padding-left"] = 20;
            } else {
                css["padding-right"] = 20;
            }
        }

        if($options.has_icon){
            $('<i class="toast-icon toast-icon-' + type + '"></i>').appendTo($element);
            if( $options.rtl){
                css["padding-right"] = 50;
            } else {
                css["padding-left"] = 50;
            }            
        }

        if($options.has_progress && $options.timeout > 0){
            $('<div class="toast-progress"></div>').appendTo($element);
        }

        if($options.stack){
            if($options.position_class.indexOf("toast-top") !== -1 ){
                $($options.appendTo).find('.toast-item-wrapper').each(function(){
                    css["top"] = parseInt($(this).css("top")) + this.offsetHeight + $options.spacing;
                });
            } else if($options.position_class.indexOf("toast-bottom") !== -1 ){
                $($options.appendTo).find('.toast-item-wrapper').each(function(){
                    css["bottom"] = parseInt($(this).css("bottom")) + this.offsetHeight + $options.spacing;
                });
            }
        }        

        $element.css(css);

        $element.appendTo($options.appendTo);

		if($element.fadeIn) {
            $element.fadeIn();
        }else {
            $alert.css({display: 'block', opacity: 1});
        }

		function removeToast(){          
			$.Toast.remove( $element );
		}

		if($options.timeout > 0){
			setTimeout(removeToast, $options.timeout);
            if($options.has_progress){
                $(".toast-progress", $element).animate({"width":"100%"}, $options.timeout);
            }
		}        

        $(".toast-close", $element).click(removeToast)

        return $element;
    }

    $.Toast.remove = function( $element ){
        "use strict";        
		if($element.fadeOut)
		{
			$element.fadeOut(function(){
				return $element.remove();
			});
		}
		else{
			$element.remove();
		}        
    }
})();