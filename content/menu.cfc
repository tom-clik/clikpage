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
		variables.static_css = {"menus"=1};
		variables.static_js ={"menus"=1};
		
		this.varClasses = ['orientation','mode','borders','align','stretch','submenualign'];
		
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

// TODO: audit this

// --submenualign: bottom-left; /* (top|bottom)-(left|right) */
// 	--submenu-position: absolute; /* absolute | relative */
// 	--submenu-display: none; /* none|block */
// 	--stretch: 1; /* 1|0 */
// 	--menu-border-color:var(--link-color);
// 	--menu-background: transparent;
// 	--menu-item-padding: 0 8px;
// 	--menu-item-border:0;/* item border width */
// 	--menu-item-width: 140px; /* min width of menu items in grid layou */
// 	--menu-icon-display: none;/* none or block */
// 	--menu-label-display: block;/* text part of menu item:; none or block */
// 	--icon-width:32px;/* normal menu icons */
// 	--icon-height:32px;	
// 	--menu-icon-valign: middle;/* WIP */
// 	--menu-icon-gap: 8px;/* gap between label and icon */
// 	--menu-icon-stretch: 1;/* stretch labels to fill remaining space */
// 	--menu-icon-align: row; /* flex direction for icon alignment */
// 	--menu-openicon-width:16px;/* "openicon" is the automatic icon applied for sub menus. Needs work */
// 	--menu-openicon-height:16px;	
// 	--menu-openicon-adjust: -4px;
// 	--menu-text-align: center;/* alignment of text in menu items */
// 	--menu-anim-time: 0.3s;
// 	--menu-direction: row;
// 	--menu-item-justify: center; /* item aligment start|center|end. Also see menu-text-align which usually needs setting as well */
// 	--menu-item-align: center; /* cross axis aligment, e.g. vertical when menu is horizontal */
// 	--menu-wrap: wrap;
// 	--rollout: 0;


		this.styleDefs = [
			"mode":{"name"="Grid mode","type"="list","default"="flex","setting":1,"options":[
					{"name"="Grid","value"="grid","description"=""},
					{"name"="Flex","value"="flex","description"=""}
				],
				"description":"Select the way your menu is laid out"
			},
			"orientation":{
				"type":"list",
				"name": "Orientation",
				"description": "Align the menu horizontally or vertically.",
				"default":"horizontal",
				"setting": 1,
				"options":[
					{"name":"Horizontal","value":"horizontal"},
					{"name":"Vertical","value":"vertical"}
				]
			},
			"link-color":{"type":"color","name":"Link colour","description":"Colour of the menu items"},
			"menu-gap":{"type":"dimension","name":"Gap","description":"Gap between menu items"},
			"menu-text-align":{"type":"halign","name":"Text align","description":"Alignment of the menu items"},
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
			"borders": {
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
			"menu-stretch": {
				"type":"boolean",
				"name":"Stretch",
				"description":"Stretch out the menu in flex mode. Equal padding will be added to the items",
				"requires": {"flex": true},
				"inherit":true,
				"default":false
			},
			"menu-reverse": {
				"type":"boolean",
				"name":"Reverse",
				"description":"Reverse the order of the items (Flexible mode only)",
				"requires": {"flex": true},
				"inherit":true,
				"default":false
			},
			"menu-wrap":{"name":"Flex wrap","description":"Wrap items onto multiple lines","type"="list","default"="wrap","options"=[
					{"name"="Wrap","value"="wrap","description"=""},
					{"name"="No Wrap","value"="nowrap","description"=""},
					{"name"="Wrap reverse","value"="wrap-reverse","description"=""}
				], "requires": {"flex": true}
			},
			"align":{
				"type":"halign",
				"name": "Menu alignment",
				"default":"left",
				"inherit":true,
				"description":"Which direction to align the menu."
			},
			"menu-border-color": {
				"name":"Border colour","type":"color","description":"", "default":"link-color"
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
		
		// flex | adjust menu-display to flex or block
		data.main &= "--menu-display: " & ( arguments.styles.flex ? "flex" : "block")  & ";\n";// 
		
		//  horizontal|vertical   | 
		local.isVertical = arguments.styles.orientation eq "vertical";
		
		if (arguments.styles.flex) {
			local.reverse = arguments.styles["menu-reverse"] ? "-reverse" : "";
			data.main &= "/* orientation: #arguments.styles.orientation#  */\n";
			data.main &= "--menu-direction: " & (local.isVertical ? "row" : "column" ) & local.reverse & ";\n";// 
		}	
		else if (local.isVertical eq "vertical") {
			// ul Grid columns
			data.ul &= "grid-template-columns: 1fr;\n";
		}
		

		// align          | left|center|right     | text align (menu text align) and also justify-content: for flex modes
		data.main &= "--menu-text-align: #arguments.styles.align#;\n";
		
		switch (arguments.styles.align) {
			case "left":
				local.justify = "flex-start";
			break;
			case "center":
				local.justify = "center";
			break;
			case "right":
				local.justify = "flex-end";
			break;
		}
		if (!local.isVertical) {
			data.main &= "--menu-item-justify: #local.justify#;\n";
		}
		
		// border-type    | normal|dividers|boxes | adjust border widths for edges
		if (StructKeyExists(arguments.styles,"border-type")) {
			// seems verbose but actually works better in terms of inheritance etc
			// as close as we can get to using simple vars for this job		
			switch (arguments.styles["border-type"]) {
				case "dividers":
					if (local.isVertical) {
						data.main &= "--menu-item-border-width: 0  0 var(--menu-item-border) 0;\n";
					}
					else {
						data.main &= "--menu-item-border-width: 0 var(--menu-item-border) 0 0;\n";
					}
					data.last &= "--menu-item-border-width:0;\n";					
					break;
				case "boxes":
					if (local.isVertical) {
						data.main &= "--menu-item-border-width: var(--menu-item-border) var(--menu-item-border) 0 var(--menu-item-border);\n";
					}
					else {
						data.main &= "--menu-item-border-width: var(--menu-item-border) 0 var(--menu-item-border) var(--menu-item-border);\n";
					}
					data.last &= "--menu-item-border-width: var(--menu-item-border);\n";
					break;
			}

		}

		//popup          | boolean               | height: 0   NB &.open  applies height:auto
		// Don't think this is implemented.
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