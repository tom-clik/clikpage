component extends="contentSection" {

	variables.type = "menu";
	variables.title = "Menu";
	variables.description = "CSS list with styling and interactive options";
	variables.defaults = {
		"title"="Untitled Menu",
		"content"="Undefined menu",
	};
	
	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		// static css definitions
		variables.static_css = {"menus"=1,"icons"=1};
		variables.static_js ={"menus"=1};
		
		this.panels = [
			{"panel":"item", "name":"Item", "selector": " li a"},
			{"panel":"subitem", "name":"Sub menu Item", "selector": " .submenu li a"},
			{"panel":"first", "name":"First", "selector": " > li:first-of-type a"},
			{"panel":"last", "name":"Last", "selector": " > li:last-of-type a"}
		];

		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=":hover","name":"Hover","description":"The hover state for menu items"},
			{"state"="hi", "selector"=".hi","name":"Hilighted","description":"The state for the currently selected menu item"}
		];		

		this.selectors = [
			{"name"="main", "selector"=""},
			{"name"="ul", "selector"=" > ul"},
			{"name"="li", "selector"=" > ul > li"},
			{"name"="a", "selector"=" > ul > li > a"},
			{"name"="first", "selector"=" > ul > li:first-of-type > a"},
			{"name"="last", "selector"=" > ul > li:last-of-type > a"},
			{"name"="submenu", "selector"=" ul.submenu"},
			{"name"="subsubmenu", "selector"=" ul.submenu ul.submenu"}
		];

		this.styleDefs = [
			"orientation":{
				"type":"list",
				"name": "Orientation",
				"description": "Align the menu horizontally or vertically.",
				"default":"horizontal",
				"options":[
					{"name":"Horizontal","value":"horizontal"},
					{"name":"Vertical","value":"vertical"}
				],
				"inherit":true
			},
			"link-color":{"type":"color","name":"Link colour","description":"Colour of the menu items"},
			"menu-gap":{"type":"dimension","name":"Gap","description":"Gap between menu items"},
			"menu-text-align":{"type":"halign","name":"Text align","description":"Alignment of the menu items"},
			"menu-anim-time":{"type":"time","name":"","description":""},
			"menu-label-display": {
				"type":"displayblock",
				"name":"Display label",
				"description":"Show or hide the text part of the menu items",
				"default":"block"
			},
			"menu-icon-display": {
				"type":"displayblock",
				"name":"Display icon",
				"description":"Show or hide the icon in the menu item. You will need to define the icons  (how TBC)",
				"default":"none"
			},
			"border-type": {
				"type":"list",
				"name":"Border type",
				"description":"",
				"default":"none",
				"inherit":true,
				"options":[
					{"value":"normal","name":"Normal"},
					{"value":"dividers","name":"Dividers"},
					{"value":"boxes","name":"Boxes"}
				]
			},
			"flex": {
				"type":"boolean",
				"name":"Flex mode",
				"description":"Flexible grid that adjusts to the size of the items",
				"inherit":true,
				"default":false
			},
			"stretch": {
				"type":"boolean",
				"name":"Stretch",
				"description":"Stretch out the menu in flex mode. Equal padding will be added to the items",
				"inherit":true,
				"default":false
			},
			"flex-wrap":{"name":"Flex wrap","dependson":"flex","dependvalue":true,"description":"Wrap items onto multiple lines","type"="list","default"="wrap","options"=[
				{"name"="Wrap","value"="wrap","description"=""},
				{"name"="No Wrap","value"="nowrap","description"=""},
				{"name"="Wrap reverse","value"="wrap-reverse","description"=""}
			]},
			"align":{
				"type":"halign",
				"name": "Menu alignment",
				"default":"left",
				"inherit":true,
				"description":"Which direction to align the menu. Only applies if you have set a width or are using Flex mode without stretch"
			},
			"menu-border-color": {
				"name":"Border colour","type":"color","description":"", "default":"--link-color"
			},
			"menu-background": {
				"name":"Background","type":"color","description":"", "default":"transparent"
			},
			"menu-item-padding": {
				"name":"","type":"dimensionlist","description":"", "default":"0 8px"
			},
			"menu-item-border": {
				"name":"Border with","type":"dimensionlist","description":"", "default":"0"
			},
			"icon-width": {
				"name":"Width of menu icons","type":"dimension","description":"", "default":"32px"
			},
			"icon-height": {
				"name":"Height of menu icons","type":"dimension","description":"", "default":"32px"
			},	
			"menu-icon-gap": {
				"name":"Gape between icon and text","type":"dimension","description":"", "default":"8px"
			},
			"menu-openicon-width": {
				"name":"Open icon width","type":"dimension","description":"", "default":"16px"
			},
			"menu-openicon-height": {
				"name":"Open icon height","type":"dimension","description":"", "default":"16px"
			},	
			"menu-openicon-adjust": {
				"name":"Menu open icon adjustment","type":"dimension","description":"", "default":"-4px"
			},
			"menu-anim-time": {
				"name":"Menu animation time","type":"dimension","description":"", "default":"0.3s"
			}
		];
		
		// Name           | Implementation
		// ---------------|----------------------
		// orientation    | ul Grid columns
		// align          | ul justify-content (NB only works for flex modes. See notes)
		// border-type    | adjust border widths for edges
		// flex           | ul display flex
		// stretch        | li {flex-grow:1 }
		// popup          | height: 0   NB .open  applies height:auto
		
		updateDefaults();

		return this;

		
	}		

	/**
	 * Note data for menu must be full data array. Sub menus
	 * can be generated from articles or sub sections.
	 */
	public string function html(required struct content, required struct data, class="menu") {
		return menuHTML(items=arguments.content.data);
		
	}

	/**
	 * @hint recursable method to generate html list for menu.
	 *
	 * *menu items have keys id, link, title, and optional submenu
	 * 
	 * @items         Menu items*
	 * @class         css class name to apply to ul element.
	 *
	 */
	private string function menuHTML(required array items, string class="menu" ) {

		// functionality reserved
		switch (arguments.class) {
			default:
				local.subclass = "submenu";
		}
		
		local.menu = "<ul class='#arguments.class#'>";
		
		for (local.item in arguments.items) {
			local.class = "  class='menu_#local.item.id#'";
			local.menu &= "<li><a href='#local.item.link#'#local.class#><b></b><span>#local.item.title#</span></a>";
			if (StructKeyExists(local.item,"submenu")) {
				local.menu &= menuHTML(items=local.item.submenu,class=local.subclass);
			}
			local.menu &= "</li>\n";
		}

		local.menu &= "</ul>";
		return local.menu;

	}

	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		//  horizontal|vertical   | ul Grid columns
		local.isVertical = false;
		if (StructKeyExists(arguments.styles,"orientation")) {
			data.ul &= "/* orientation: #arguments.styles.orientation#  */\n";
			
			if (arguments.styles.orientation eq "vertical") {
				local.isVertical = true;
				data.ul &= "grid-template-columns: 1fr;\n";
			}
		}
		else {
			data.ul &= "/* no orientation  */\n";
		}

		// align          | left|center|right     | text align (menu text align) and also justify-content: for flex modes
		local.align = "left";

		if (StructKeyExists(arguments.styles,"menu-text-align")) {
			data.main &= "--menu-text-align: #arguments.styles["menu-text-align"]#;\n";
		}

		if (StructKeyExists(arguments.styles,"align")) {
			if (!StructKeyExists(arguments.styles,"align")) {
				data.main &= "--menu-text-align: #arguments.styles.align#;\n";
			}
			switch (arguments.styles.align) {
				case "left":
					local.justify = "flex-start";
				break;
				case "center":
					local.justify = "center";
					local.align = "center";
				break;
				case "right":
					local.justify = "flex-end";
					local.align = "right";
				break;
			}
			if (!local.isVertical) {data.ul &= "justify-content: #local.justify#;\n";}
		}
		// border-type    | normal|dividers|boxes | adjust border widths for edges
		if (StructKeyExists(arguments.styles,"border-type")) {
			local.side = local.isVertical ? "bottom" : "right";
			local.off = local.isVertical ? "right" : "bottom";
					
			switch (arguments.styles["border-type"]) {
				case "normal":
					// TODO:  check specificity actually works. May need to get value of right border
					data.a &= "border-width:var(--menu-item-border);\n";
					data.last &= "border-width:var(--menu-item-border);\n";
					break;
				case "dividers":
					data.a &= "border-width:0;\n";
					data.a &= "border-#local.side#-width:var(--menu-item-border);\n";
					data.last &= "border-width:0;\n";					
					break;
				case "boxes":
					data.a &= "border-width:var(--menu-item-border);\n";
					data.a &= "border-#local.side#-width:0;\n";
					data.last &= "border-#local.side#-width:var(--menu-item-border);\n";
					break;
			}

		}

		//flex           | boolean               | ul display flex
		if (StructKeyExists(arguments.styles,"flex")) {
			data.ul &= "/* flex */\n";
			data.ul  &= "display: " & (arguments.styles.flex AND NOT local.isVertical ? "flex" : "grid") & ";\n";
			if (StructKeyExists(arguments.styles,"flex-wrap")) {
				data.ul  &= "flex-wrap: " & arguments.styles["flex-wrap"] & ";\n";
			}
		}
		//stretch        | boolean               | li flex-grow:1
		if (StructKeyExists(arguments.styles,"stretch")) {
			data.li &= "/* stretch #arguments.styles.stretch# */\n";
			data.li &= "flex-grow: " & (arguments.styles.stretch ? "1" : "0") & ";\n";
		}
		//popup          | boolean               | height: 0   NB &.open  applies height:auto
		// to check functionality here. Don't think this is used.
		if (StructKeyExists(arguments.styles,"popup")) {
			data.main &= "/* popup styling */\n";
			// expects decreasing media width
			if (arguments.styles.popup) {
				data.main &= "height:0;\n";
				data.main &= "overflow: hidden;";
			}
		}

		// submenu position | inline|relative    | position:absolute or static no ul.submenu
		local.submenu_position =  arguments.styles.submenu_position ?: "absolute";
		data.submenu &= "/* submenu styling */\n";
		data.submenu &= "position: #local.submenu_position#;\n";
		data.subsubmenu &= "/* subsubmenu styling */\n";
		data.subsubmenu &= "position: #local.submenu_position#;left:100%;top:0;\n";
		// submenu relative to   |   item | menu    | Javascript needed for most of these options. Default set top: 100%, let:0

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);
	}	
	
	public string function onready(required struct content) {
		var js = "$(""###arguments.content.id#"").menu();\n";
		return js;
	}

}