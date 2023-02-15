<!--

# Parrallax Demo Page



## Synopsis



-->

<!DOCTYPE html>
<html>

<head>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<style>
	body {
		background-color: #ccc;
		padding:0;
	}

	

	.imageContainer {
		height:430px;
		position: relative;
		z-index: 1;
		overflow: hidden;
	}

	.imageInner {
		background-color: transparent;
	    background-repeat: no-repeat;
	    background-image: url(../images/mica-mota-Y1OUQTZRqMo-unsplash.jpg);
	    background-size: cover;
	    background-position: center top;
	    width: 100%;
	    height: 100%;
	    z-index: 0;
	}

	.imageTitle {
		position: absolute;
		top:50%;
		left:50%;
		transform: translate(-50%,-50%);
		font-size: 48px;
		color: white;
	}

	.text {
		padding:20px;
		margin:12px auto;
		max-width: 800px;
	}

	</style>
</head>

<body>

	<div id="ubercontainer">
		<div class="text">
			<cfoutput>#menuText(2)#</cfoutput>
		</div>

		<div class="imageContainer">
			<div class="imageInner">
			</div>
			<div class="imageTitle">
				Caption here
			</div>
		</div>
		<div class="text">
			<cfoutput>#menuText(10)#</cfoutput>
		</div>
	</div>
</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.throttledresize.js"></script>
<script>
$( document ).ready(function() {
	// could do with throttling
	$image = $(".imageInner");
	$container = $(".imageContainer");
	$title = $(".imageTitle");
	height = $container.height();

	$(window).on('scroll', function() {
		var top = $(window).scrollTop() 
		var anchor_offset = $container.offset().top;
		console.log(top);

		if (top > anchor_offset) {
			if (top < height + anchor_offset) {
				top = (top - anchor_offset) / 2 ;
			} else {
				top = height;
			}
		}
		else {
			top = 0;
		}

		$image.css("transform","translate(0," + top + "px)");
		
	});

	
});
</script>

</html>

<cffunction name="menuText">
	<cfargument name="count" default="5">
	<cfset var retVal = "">
	<cfloop index="i" from="1" to="#arguments.count#">
		<cfset retVal &= "<div>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</div>">
	</cfloop>
	<cfreturn retVal>
</cffunction>