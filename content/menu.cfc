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
		
		this.classes = "menu";

		this.panels = [
			{"panel":"item", "name":"Item", "selector": " li a"},
			{"panel":"subitem", "name":"Sub menu Item", "selector": " .submenu li a"}
		];

		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
			{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
		];		


		this.styleDefs = [
			"mode":{"name"="Grid mode","type"="list","default"="flex","options":[
					{"name"="Grid","value"="grid","description"="Menu with all items the same size"},
					{"name"="Flex","value"="flex","description"="Flexible menu with items adjusted to their content"}
				],
				"description":"Select the way your menu is laid out"
			},
			"menu-orientation":{
				"type":"list",
				"name": "Orientation",
				"description": "Align the menu horizontally or vertically.",
				"default":"horizontal",
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
			"menu-borders": {
				"type":"list",
				"name":"Border type",
				"description":"",
				"default":"none",
				"inherit":true,
				"options":[
					{"value":"normal","name":"Normal","Description":"The border is applied to each item as specified here"},
					{"value":"dividers","name":"Dividers","Description":"The border is applied between the items. Enter a single dimension value in menu-item-border."},
					{"value":"boxes","name":"Boxes","Description":"The border is applied around them items without doubling up. Enter a single dimension value in menu-item-border."}
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
			"menu-align":{
				"type":"halign",
				"name": "Menu alignment",
				"default":"left",
				"inherit":true,
				"description":"Which direction to align the menu."
			},
			"menu-border-color": {
				"name":"Border colour","type":"color","description":"Border colour", "default":"link-color"
			},
			"menu-background": {
				"name":"Background","type":"color","description":"Background of the menu items", "default":"transparent"
			},
			"menu-item-padding": {
				"name":"","type":"dimensionlist","description":"Item padding", "default":"0 8px"
			},
			"menu-item-border": {
				"name":"Border with","type":"dimensionlist","description":"Border width. See also menu-borders", "default":"0"
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
		
		updateDefaults();

		return this;

		
	}		

	/**
	 * Note data for menu must be full data array. Sub menus
	 * can be generated from articles or sub sections.
	 */
	public string function html(required struct content) {
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
	private string function menuHTML(required array items) {

		local.menu = "<ul>";
		
		for (local.item in arguments.items) {
			local.class = "  class='menu_#local.item.id#'";
			local.iconClass = "icon-" & ( local.item.icon ? : "" ); 
			local.menu &= "<li><a href='#local.item.link#'#local.class#><i class='#local.iconClass#'></i><span>#local.item.title#</span></a>";
			if (StructKeyExists(local.item,"submenu")) {
				local.menu &= "<div class='menu submenu'>" & menuHTML(items=local.item.submenu) & "</div>";
			}
			local.menu &= "</li>\n";
		}
		local.menu &= "</ul>";

		return local.menu;

	}

	public string function onready(required struct content) {
		var js = "$(""###arguments.content.id#"").menu();\n";
		return js;
	}

}