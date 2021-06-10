/* Static component for creating and handling content sections


*/

component {

	function init(required contentObj contentObj) {
		
		variables.contentObj = arguments.contentObj;
		variables.type = "base";
		variables.title = "Base component";
		variables.description = "The base component shouldn't be used directly.";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined base component",
		};
		variables.static_css = {};
		variables.static_js = {};

		return this;
	}

	/** Create a new content section */
	public struct function new(required string id, string type=variables.type, string class, string title, string content,string image, string caption, string link) {
		var cs = {"id"=arguments.id,"type"=arguments.type, "class"={}};
		if (StructKeyExists(arguments,"content")) {
			cs["content"] = arguments.content;
		}
		if (StructKeyExists(arguments,"image")) {
			cs["image"] = arguments.image;
		}
		if (StructKeyExists(arguments,"caption")) {
			cs["caption"] = arguments.caption;
		}
		if (StructKeyExists(arguments,"title")) {
			cs["title"] = arguments.title;
		}
		if (StructKeyExists(arguments,"link")) {
			cs["link"] = arguments.link;
		}
		if (StructKeyExists(arguments,"class")) {
			cs["class"][arguments.class] = 1;
		}

		StructAppend(cs,variables.defaults,false);
		cs.class["cs-#variables.type#"] = 1;
		return cs;
	}

	public string function html(required struct content) {
		return arguments.content.content;
	}

	public string function css(required struct settings, string selector) {
		return "/* #variables.type# css no custom css */\n";
	}
	
	public struct function settings(required struct content) {
		if (! StructKeyExists(arguments.content,"settings")) {
			arguments.content["settings"] = {
				"main" = {}
			};	
		}

		return arguments.content["settings"];
	}
			

	public struct function getStaticCss() {
		return variables.static_css;
	}

	public struct function getStaticJs() {
		return variables.static_js;
	}

	public string function onready(required struct content) {
		var js = "";

		return js;
	}

}