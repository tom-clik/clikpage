<!--

# Animate Auto Demo Page

You cannot use CSS to animate to a height of auto. To do this requires some javaScript. 

We have a generic utility to do this.

## Synopsis

Apply open and close events to a menu that call animateAuto on open and normal animate on close.

Use autoButton to call these methods from a button.

Only the vertical menu uses animate auto. A side menu is shown using CSS transitions.

-->

<!DOCTYPE html>
<html>

<head>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/menus.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/schemes/menus-schemes.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
	<style>
	body {
		padding:20px;
		background-color: #ccc;
	}

	#ubercontainer {
		background-color: #fff;
		border: 1px solid #000;
		padding:20px;
		margin: 0 auto;
		max-width: 660px;
	}

	.section {
		margin:20px;
		border: 1px solid #000;
		padding:20px;
	}

	#mainmenu {
		overflow: hidden;
		height:0px;
	}

	#sidemenu {
		position: fixed;
		top:0;
		left:0;
		transform: translate(-100%, 0);
		width:460px;
		height: 100vh;
		background-color: white;
		overflow: hidden;
		transition: transform 0.6s ease-in;
		padding:20px;
	}
	
	#sidemenu.open {
		transform: translate(0);
	}

	#popmenu_button {
		position: absolute;
		top:20px;
		left:20px;
	}
	</style>
</head>

<body>

	<div id="ubercontainer">

		<div class="button scheme-hamburger scheme-headerbutton" id="mainmenu_button">
			<a href="#mainmenu.open">
				<div class="icon">
					<svg   viewBox="0 0 32 32"><use xlink:href="/_assets/images/menu.svg#menu"></svg>
				</div>
			</a>
			<a href="#mainmenu.close">
				<div class="icon">
					<svg   viewBox="0 0 357 357"><use xlink:href="/_assets/images/close47.svg#close"></svg>
				</div>
			</a>
		</div>

		<div id="mainmenu">
			<cfoutput>#menuText(10)#</cfoutput>
		</div>	
	</div>

	<div class="button scheme-hamburger scheme-headerbutton" id="popmenu_button">
		<a href="#sidemenu.open">
			<svg class="icon" viewBox="0 0 32 32"><use xlink:href="/_assets/images/menu.svg#menu"></svg>
		</a>
	</div>

	<div id="sidemenu">
		<div class="button scheme-hamburger scheme-headerbutton" id="popmenu_close_button">
			<a href="#sidemenu.close">
				<svg class="icon" viewBox="0 0 357 357"><use xlink:href="/_assets/images/close47.svg#close"></svg>
			</a>
		</div>
		<cfoutput>#menuText(10)#</cfoutput>
	</div>

</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.autoButton.js"></script>
<script src="/_assets/js/jquery.animateAuto.js"></script>

<script>


	$(document).ready(function() {

		$(".button").button();
		
		menuAnimationTime = 500;

		// auto func note the classes don't do anything.
		$("#mainmenu").on("open",function() {
			console.log("opening " + $(this).attr("id"));
			$(this).addClass("open").animateAuto("height", menuAnimationTime, function() {
				console.log("Animation complete");	
				$(this).css({"height":"auto"});
			});

		}).on("close",function() {
			console.log("closing " + $(this).attr("id"));
			$(this).removeClass("open").animate({"height":0}, menuAnimationTime, function() {});
		});

		$("#sidemenu").on("open",function() {
			console.log("opening " + $(this).attr("id"));
			$(this).addClass("open");
		}).on("close",function() {
			console.log("closing " + $(this).attr("id"));
			$(this).removeClass("open");
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