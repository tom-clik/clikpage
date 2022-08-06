/*

New menu component for var based stying.

*/
component extends="test_csbase" {

	public function init() {
		super.init();

		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
			{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
		]
		

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
			"menu-icon-display": {"type":"boolean","name":"Display icon","description":"Show or hide the icon in the menu item. You will need to define the icons  (how TBC)","default":false}
		];
		// pending formal definitions of settings,
		// there are some settings that need to cascade, e.g. orientation
		// 
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
			"orientation": {"inherit":1},
			"border-type": {"inherit":1}
		];

		
	}
	
	private string function css_settings(required string selector, required struct styles) {
		
		var data = getSelectorStruct();
		
		//  horizontal|vertical   | ul Grid columns
		local.isVertical = false;
		if (StructKeyExists(arguments.styles,"orientation")) {
			data.ul &= "/-- orientation: #arguments.styles.orientation#  --/\n";
			
			if (arguments.styles.orientation eq "vertical") {
				local.isVertical = true;
				data.ul &= "grid-template-columns: 1fr;\n";
			}
		}
		else {
			data.ul &= "/-- no orientation  --/\n";
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
		if (StructKeyExists(arguments.styles,"padding-adjust") AND arguments.styles.padding-adjust) {
			// TODO: check we don't have  specificity nightmare
			data.first &= "/-- padding-adjust  --/\n";
			data.first &= "padding-left:0;\n";
			data.last &= "/-- padding-adjust  --/\n";
			data.last &= "padding-right:0;\n";
		}
		//flex           | boolean               | ul display flex
		if (StructKeyExists(arguments.styles,"flex")) {
			data.ul &= "/-- flex --/\n";
			data.ul  &= "display: " & (arguments.styles.flex AND NOT local.isVertical ? "flex" : "grid") & ";\n";
		}
		//stretch        | boolean               | li flex-grow:1
		if (StructKeyExists(arguments.styles,"stretch")) {
			data.li &= "/-- stretch #arguments.styles.stretch# --/\n";
			data.li &= "flex-grow: " & (arguments.styles.stretch ? "1" : "0") & ";\n";
		}
		//popup          | boolean               | height: 0   NB &.open  applies height:auto
		if (StructKeyExists(arguments.styles,"popup")) {
			data.main &= "/-- popup styling --/\n";
			// expects decreasing media width
			if (arguments.styles.popup) {
				data.main &= "height:0;\n";
				data.main &= "overflow: hidden;";
			}
		}
		// submenu position | inline|relative    | position:absolute or static no ul.submenu
		local.submenu_position =  arguments.styles.submenu_position ?: "absolute";
		data.submenu &= "/-- submenu styling --/\n";
		data.submenu &= "position: #local.submenu_position#;\n";
		data.subsubmenu &= "/-- subsubmenu styling --/\n";
		data.subsubmenu &= "position: #local.submenu_position#;left:100%;top:0;\n";
		// submenu relative to   |   item | menu    | Javascript needed for most of these options. Default set top: 100%, let:0

		return selectorQualifiedCSS(selector=arguments.selector, css_data=data);
	}

	public function html(data, selected='',class="") {
		
		local.classStr = arguments.class eq "" ? "" : " class='#arguments.class#'";

		var retval = "<ul#local.classStr#>";

		for (local.item in arguments.data) {
			local.hi = local.item.code eq arguments.selected ? " class='hi'" : "";
			local.link = StructKeyExists(local.item,"link") ? local.item.link : "##";
			retval &= "<li#local.hi#><a class='menu_#local.item.code#' href='#local.item.link#'><b></b><span>#local.item.title#</span></a>";
			if (structKeyExists(local.item, "menu")) {
				retval &= html(data=local.item.menu,selected=arguments.selected,class=ListAppend(arguments.class,"submenu"," "));
			}
			retval &= "</li>";
		}

		retval &= "</ul>";
	
		return retval;
	}

	/**
	 * Construct a sample menu
	 * 
	 * @count max items in menu
	 * @level reserved by system for recursion
	 */
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
				local.item["menu"] = getSampleMenuData(count=RandRange(3,5),level=arguments.level + 1);
			}
			ArrayAppend(menuData,local.item);			
		}

		return menuData;
	}



}
