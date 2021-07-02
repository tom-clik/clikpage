component extends="contentSection" {
	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "menu";
		variables.title = "Menu content section";
		variables.description = "Menu list";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};
		// static css definitions
		variables.static_css = {"menus"=1};
		variables.static_js ={"menus"=1};
		variables.settings = {
			"menu" = {
				"orientation" 	= "horizontal",
				"flex" = false
			}
		};
		
		variables.panels = [
			{"name":"item", "selector": " li"}
		];

		return this;

	}
	/** TODO: remove and validate properly somewhere */
	private array function getFakeData(boolean submenu=false) {
		
		local.data = [];
		for (local.i = 1; local.i <= 5; local.i++ ) {
			local.title = Left("Lorem ipsum dolor sit amet",randRange(12,20));
			local.menu = {"link"="link#local.i#.html","section"="link#local.i#","title"=local.title};
			if (!arguments.submenu && local.i % 2 == 1) {
				local.menu["submenu"] = getFakeData(submenu=true);
			}
			ArrayAppend(local.data,local.menu);


		}

		return local.data;
	}

	public string function html(required struct content, class="menu") {

		if (! StructKeyExists(arguments.content,"data")) {
			arguments.content.data = getFakeData();
		}

		return menuHTML(menu=arguments.content.data);
		
	}

	/**
	 * recursable method to generate html list for menu.
	 * 
	 * @menu          Array of menu items
	 * @class         css class name to apply to ul element.
	 */
	private string function menuHTML(required array menu, string class="menu" ) {
		
		switch (arguments.class) {
			default:
				local.subclass = "submenu";
		}
		
		local.menu = "<ul class='#arguments.class#'>";
		
		for (local.item in arguments.menu) {
			local.menu &= "<li id='menu_#local.item.section#'><a href='#local.item.link#'>#local.item.title#";
			if (StructKeyExists(local.item,"submenu")) {
				local.menu &= menuHTML(menu=local.item.submenu,class=local.subclass);
			}
			local.menu &= "</a></li>\n";
		}

		local.menu &= "</ul>";
		return local.menu;

	}



	public string function css(required struct settings, required string selector) {
			
		var ret = "";
		var t = "";

		local.settings = arguments.settings.menu;

		ret &= arguments.selector  & " ul {\n";

		if (StructKeyExists(local.settings,"min-height")) {
			ret &= "\tmin-height: #local.settings["min-height"]#;\n";
		}

		if (local.settings.orientation eq "vertical") {
			ret &= "\tdisplay: grid;\n";
			ret &= "\tgrid-template-columns: 1fr;\n";
		}
		else {
			if (local.settings.flex) {
				ret &= "\tdisplay: flex;\n";
				ret &= "\tflex-wrap: wrap;\n";
				ret &= "\tflex-direction: row;\n";
				if (StructKeyExists(local.settings,"align")) {
					switch(local.settings.align) {
						case "left":
							ret &= "\tjustify-content: flex-start;\n";
							break;
						case "right":
							ret &= "\tjustify-content: flex-end;\n";
							break;
						case "spaced":
							ret &= "\tjustify-content: space-evenly;\n";
							break;
					}
					
				}
			}
			else {
				ret &= "\tdisplay: grid;\n";
				ret &= "\tgrid-template-columns: repeat(auto-fill, minmax(100px,1fr));\n";
			}
		}

		for (local.setting in ["menucolor","menuhicolor","menubordercolor","menuactivecolor","menugap","menucolumngap","menuitempadding"]) {
			if (StructKeyExists(local.settings,local.setting)) {
				ret &= "\t--#local.setting#:" & local.settings["#local.setting#"] & ";\n";
			}
		}

		ret &= "}\n";
		
		return ret;
	}

	public string function onready(required struct content) {
		var js = "$(""###arguments.content.id#"").menu();\n";

		return js;
	}

}