// Not sure how to handle this at the minute. Add
// yet another onready here. Really we want this as a plug in 
// we call like the others (tabs etc) in clik_onready

$(document).ready(function() {
	
	$(document)
		.on( "mouseenter", "body.wireframe div:not(.cs,.inner)", function(e) { 
				e.stopPropagation();
				$("div.hover").removeClass("hover");
				$(this).addClass("hover");
			} )
		.on( "mouseleave", "body.wireframe div:not(.cs,.inner)", function(e) { 
			$(this).removeClass("hover");
			} );

	$(window).on("keydown.edit", function( event ) {
		let hasAction = false;
		console.log(event.key);			
		switch (event.key) {
			case "Escape":
	  			$("body").removeClass("wireframe");
	  			hasAction = true;
	  		break;
		  	case "W": case "w":
	  			$("body").toggleClass("wireframe");
	  			hasAction = true;
	  		break;

	  		// case "ArrowLeft":
	  		// event.preventDefault();
	  		// plugin.previous();
	  		// break;
	  		// case "ArrowRight":
	  		// event.preventDefault();
	  		// plugin.next();
	  		// break;
	  	}	  	 	
	  	if (hasAction) {
		  	event.preventDefault();
		  	event.stopPropagation();
	  	}
	});

});
