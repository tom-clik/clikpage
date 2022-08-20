<!---

## Settings

# Working ok by classes

Need to get it cf'd up so we apply via settings only.

Name           | Type                  | Implementation
---------------|-----------------------|----------------------
orientation    | horizontal|vertical   | ul Grid columns
align          | left|center|right     | text align (menu text align) and also justify-content: for flex modes
border-type    | normal|dividers|boxes | adjust border widths for edges
padding-adjust | boolean               | adjust padding for first and last items
flex           | boolean               | ul display flex
stretch        | boolean               | li {flex-grow:1{}
popup          | boolean               | height: 0   NB &.open  applies height:auto

Need also to do sub menus and then think about the menu script.

See the onreadytest in ColdLight. This sort of works but needs turning into a plug in.

## States

Name   | Selector
-------|--------------------
hover  | li:hover
hi     | li.hi
     
## To Do;

-[] Icons - NB need menu icons and open indicator! Confusion here.

--->

<cfscript>
menuObj = new clikpic._testing.css_tests.menu();

styles = menuObj.newStyles();

styles.max = {
	"menu-icon-display": "inline-block",
	"align": "right",
	"menu-item-padding": "4px 12px",
	"border-type" :"boxes",
	"menu-gap":"0",
	"menu-item-border": "1px",
	"flex": 1
} 

styles.main = {
	"menu-icon-display": "none",
	"menu-item-padding": "8px",
	"flex": 0,
	"align": "center",
	"menu-gap":"6px",
	"menu-item-border": "0",
	"border-type" :"normal",
	"link-color": "Brown",
	"menu-background": "Bisque",
	"menu-item-border": "0 0 4px 0",
	"hover": {
		"link-color" : "DarkCyan",
		"menu-background" : "DarkKhaki",
		"menu-border-color" : "pink"
	},
	"hi": {
		"link-color" : "Cornsilk",
		"menu-background" : "darkslategray"
	}

}


styles.mid = {
	"flex": 0,
	"menu-gap":"0",
	"orientation": "vertical",
	"align": "left",
	"menu-item-border": "1px",
	"border-type" :"dividers",
	"submenu_position":"static",
	"menu-icon-display": "inline-block"
}

styles.mobile = {
	"width":"48px",
	"flex": 0,
	"menu-gap":"0",
	"orientation": "vertical",
	"align": "left",
	"menu-item-border": "0px",
	"border-type" :"dividers",
	"submenu_position":"static",
	"menu-label-display": "none"
}

FileWrite(ExpandPath("menu_styling.css"),menuObj.css(selector="##menu",styles=styles,debug=true),"utf-8");

</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>Menu test</title>
	<link rel="stylesheet" type="text/css" href="reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/menus.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/schemes/menus-schemes.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/fonts/google_icons.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/icons.css">
	<link rel="stylesheet" type="text/css" href="menu_styling.css">

	<meta charset="UTF-8">
	<style>
		body {
			--title-font:font-family: 'Open Sans';
		}

		.cs-title {
			font-size: 200%;
			font-weight: bold;
		}

		.title {
			font-size: 140%;
			font-weight: bold;
		}

		.cs-menu {
			margin-bottom: 12px;
		} 
		<!---
		.scheme-main {
			
		}
		.scheme-main li:hover {
			--link-color:#ffff00;
			--menu-background: #efefef;
		}

		.scheme-main li.hi {
			--link-color:#00ffff;
			--menu-background: darkslategray;
		}

		.scheme-plain {
			--menu-item-border: 1px;
		}

		#menu {
			width:<cfoutput>#menu_width#</cfoutput>;
		}

		#menu {
			--menu-icon-display: inline-block;
			/*--menu-icon-display: none;*/
		}

		@keyframes Animation { 
		    0%{background-position:10% 0%}
		    50%{background-position:91% 100%}
		    100%{background-position:10% 0%}
		}

		@keyframes Animation2 {
			0%{width:0%}
		    20%{width:16.5%}
		    50%{width:33%}
		    100%{width:100%}
		}
		
		@media screen AND (max-width: 800px) {
			#menu {
				--menu-icon-display: none;
			}
			#menu > ul li:after {
				margin:2px 0 0 auto;
				content: " ";
					display: block;
					height:4px;
					width:0;
					
			}
			#menu > ul li:hover:after {
				width:100%;
				transition: width 0.5s  cubic-bezier(0.25, 0.1, 0.25, 1);
				background: linear-gradient(90deg,  #ffffff, #ff00ff);
			}


			/*#menu > ul li:hover:after {
				background: linear-gradient(130deg, #ff7e00, #ffffff, #5cff00);
				background-size: 200% 200%;
				animation: Animation 3s ease infinite;
			}*/
						

		}

		--->
		
		@media screen AND (max-width: 630px) {
			#menu {
				width:48px;
				
			}
			
			 /*//don't quite understand where its getting a wdith from
			 //cs-menu a has width of 100% which is calculated as 140px but why?*/
			
		
			#menu .submenu {
				--menu-item-padding: 8px;
			}

			#menu .submenu .submenu {
				--menu-item-padding: 8px;
			}

			#menu .submenu {
				display:none;
			}

			#menu .icon {
				display:none;
			}

		}		

		#menu .submenu {
			--menu-icon-display: none;
		}
		
		#menu .menu_sample1-1  {
			--menu-icon: var(--icon-home);
		}
		#menu .menu_sample2-1  {
			--menu-icon: var(--icon-search);
		}
		#menu .menu_sample3-1  {
			--menu-icon:var(--icon-last_page);
		}
		#menu .menu_sample4-1  {
			--menu-icon: var(--icon-favorite);
		}
		#menu .menu_sample5-1  {
			--menu-icon: var(--icon-account);
		}
		#menu .menu_sample6-1  {
			--menu-icon: var(--icon-cart);
		}
		#menu .menu_sample7-1  {
			--menu-icon: var(--icon-done);
		}
		#menu .menu_sample8-1  {
			--menu-icon: var(--icon-fullscreen_exit);		}

		
	</style>
</head>
<body>

<div class="cs-title">
Menu Testing
</div>

<cfset menu = menuObj.html(menuObj.getSampleMenuData(),"sample2-1")>
<cfset bigmenu = menuObj.html(menuObj.getSampleMenuData(12),"sample2-1")>

<div id="menu" class="cs-menu test1"><cfoutput>#menu#</cfoutput></div>

<script src="/_assets/js/jquery-3.4.1.js"></script>
<script src="/_assets/js/jquery.animateAuto.js"></script>
<script src="/_assets/js/jquery.menu.js"></script>

<script>
	
	$(document).ready(function() {
		
		$('#menu').menu({
			debug:true
		});
	
	});

</script>

</body>
</html>
