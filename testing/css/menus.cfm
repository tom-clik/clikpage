<!---

## Status

WIP converting to formal cs. NB menu.cfc in this folder deprecated.
     
## To Do

- [ ] Align - not working in other media
- [ ] Icons - NB need menu icons and open indicator! Confusion here.

--->

<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));

contentObj.debug = 1;

menustyles = {};

menustyles.main = {
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

menustyles.max = {
	"menu-icon-display": "inline-block",
	"menu-text-align": "right",
	"menu-item-padding": "4px 12px",
	"border-type" :"boxes",
	"menu-gap":"0",
	"menu-item-border": "1px",
	"flex": 1,
	"stretch":1
}


menustyles.mid = {
	"width":"120px",
	"flex": 0,
	"menu-gap":"0",
	"orientation": "vertical",
	"align": "left",
	"menu-item-border": "1px",
	"border-type" :"dividers",
	"submenu_position":"static",
	"menu-icon-display": "inline-block"
}

menustyles.mobile = {
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

styles.content["menu"] = menustyles;

menuCss = "/* auto generated by menus.cfm test page */" & NewLine();

menu_cs = contentObj.new(id="menu",type="menu");
menu_cs["data"] = getSampleMenuData();

site.cs = {
	"menu" = menu_cs
};

menuCss &= contentObj.contentCSS(styles=styles.content,content_sections=site.cs,media=styles.media);

menuCss = settingsObj.outputFormat(menuCss,styles.media);

FileWrite(ExpandPath("menu_styling.css"),menuCss,"utf-8");

display = contentObj.display(menu_cs);
// contentObj.addPageContent(request.prc.pageContent,display.pagecontent);

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
			--menu-icon: var(--icon-fullscreen_exit);	
	</style>
</head>
<body>

<div class="cs-title">
Menu Testing
</div>

<cfoutput>#display.html#</cfoutput>

<script src="/_assets/js/jquery-3.4.1.js"></script>
<script src="/_assets/js/jquery.animateAuto.js"></script>
<script src="/_assets/js/jquery.menu.js"></script>

<script>
	
	$(document).ready(function() {
		
		<cfscript>
		Writeoutput(display.pagecontent.onready);
		</cfscript>
		// $("#menu").menu();

	
	});

</script>

</body>
</html>


<cfscript>

public array function getSampleMenuData(count=8,level=1) {
	var menuData = [];
	local.string = "Lorem ipsum dolor sit amet, consectetur adipisicing elit";
	for (local.i =1; i lte arguments.count; i++) {
		local.start = RandRange(1,Len(local.string) - 20);
		local.end = RandRange(8, 16);
		local.title =  Mid(local.string,local.start,local.end);
		local.item = {"code"="sample#local.i#-#arguments.level#","title"=local.title};
		local.item["link"] = local.item.code & ".html";
		// add sample sub menu
		if ((local.i mod 2) eq 1 AND arguments.level < 3) {
			local.item["submenu"] = getSampleMenuData(count=RandRange(3,5),level=arguments.level + 1);
		}
		ArrayAppend(menuData,local.item);			
	}

	return menuData;
}


</cfscript>