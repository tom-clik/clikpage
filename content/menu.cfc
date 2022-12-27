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
		
		this.panels = [
			{"panel":"item", "name":"Item", "selector": " li a"}
		];

		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
			{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
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
			"orientation":{"type":"orientation"},
			"link-color":{"type":"color"},
			"menu-border-color":{"type":"color"},
			"menu-background":{"type":"color"},
			"menu-gap":{"type":"dimension"},
			"menu-item-padding":{"type":"padding"},
			"menu-item-border":{"type":"border-width"},
			"menu-text-align":{"type":"halign"},
			"menu-anim-time":{"type":"time"},
			"menu-label-display": {"type":"boolean","name":"Display label","description":"Show or hide the text part of the menu items","default":true},
			"menu-icon-display": {"type":"boolean","name":"Display icon","description":"Show or hide the icon in the menu item. You will need to define the icons  (how TBC)","default":false},
			"border-type": {"type":"list","name":"Border type","description":"","options":[
				{"value":"normal"},{"value":"dividers"},{"value":"boxes"}
			]},
			"flex": {"type":"boolean","name":"Flex mode","description":"Flexible grid that adjusts to the size of the items","default":false},
			"stretch": {"type":"boolean","name":"Stretch","description":"Stretch out the menu in flex mode. Equal padding will be added to the items","default":false},
			"popup": {"type":"boolean","name":"Popup","description":"Show as popup (you will need to ensure a button is present that opens the menu","default":false},
			"padding-adjust":{"type":"boolean","name":"Padding adjust","description":"adjust padding for first and last item (only flex"}
		];
		// ## Settings

		// Name           | Type                  | Implementation
		// ---------------|-----------------------|----------------------
		// orientation    | horizontal|vertical   | ul Grid columns
		// align          | left|center|right     | text align (menu text align) and also justify-content: for flex modes
		// border-type    | normal|dividers|boxes | adjust border widths for edges
		// padding-adjust | boolean               | adjust padding for first and last items
		// flex           | boolean               | ul display flex
		// stretch        | boolean               | li {flex-grow:1{}
		// popup          | boolean               | height: 0   NB &.open  applies height:auto

		this.settings = [
			"orientation": "horizontal",
			"align":"left",
			"border-type": "none",
			"flex":"false",
			"stretch":"false",
			"popup":"false",
			"padding-adjust": false
		];

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
		if (StructKeyExists(arguments.styles,"align")) {
			data.main &= "--menu-text-align: #arguments.styles.align#;\n";
			
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

		//padding-adjust | boolean               | adjust padding for first and last items (only makes sense for flex)
		if (arguments.styles["padding-adjust"] AND NOT local.isVertical) {
			// TODO: check we don't have  specificity nightmare
			data.first &= "/* padding-adjust  */\n";
			data.first &= "padding-left:0;\n";
			data.last &= "/* padding-adjust  */\n";
			data.last &= "padding-right:0;\n";
		}
		else {
			data.first &= "/* padding-adjust  */\n";
			data.first &= "padding:var(--menu-item-padding);\n";
			data.last &= "/* padding-adjust  */\n";
			data.last &= "padding:var(--menu-item-padding);\n";
		}

		//flex           | boolean               | ul display flex
		if (StructKeyExists(arguments.styles,"flex")) {
			data.ul &= "/* flex */\n";
			data.ul  &= "display: " & (arguments.styles.flex AND NOT local.isVertical ? "flex" : "grid") & ";\n";
		}
		//stretch        | boolean               | li flex-grow:1
		if (StructKeyExists(arguments.styles,"stretch")) {
			data.li &= "/* stretch #arguments.styles.stretch# */\n";
			data.li &= "flex-grow: " & (arguments.styles.stretch ? "1" : "0") & ";\n";
		}
		//popup          | boolean               | height: 0   NB &.open  applies height:auto
		// to check functionality here.
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