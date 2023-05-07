/**
 * # Button definition
 *
 * We do not use fonts for button definitions. Instead we use SVG files. Any icon font 
 * will have SVG equivalents to download and use.
 *
 * To allow use of external images, the following mechanism is required to apply CSS styling
 *
 * 1. An id must be applied to the actual svg definition you want to use, e.g.
 * 
 * <svg version="1.1" xmlns="http://www.w3.org/2000/svg"
	 viewBox="0 0 197.4 197.4"><polygon  id="left_arrow" points="146.88 197.4 45.26 98.7 146.88 0 152.15 5.42 56.11 98.7 152.15 191.98"/></svg>
 *
 * NB You can wrap multiple tags in a redundant <g> tag if necessary.
 * 
 * 2.You reference this ID in the HTML as an anchor on the href attribute for <use>, e.g.
 *  
 * <svg  
	viewBox="0 0 197.4 197.4"  preserveAspectRatio="none"><use href="graphics/left_arrow.svg#left_arrow"/></svg>
 *
 * 3. The viewbox should be repeated in the HTML element. There may be a better solution to this 
 * but we haven't found it.
 *
 * 4. Apply CSS styling to the HTML element. "color" is applied via "stroke" and "fill". Importantly it can be scaled with simple width and height properties.
 *
 *  Note you can combine the SVGs into a single file and it will still work. If you do this make sure the view box matches your elements. Use of e.g. bootstrap icons which all have the same viewBox is recommended.
 */

component extends="contentSection" {
	
	variables.type = "button";
	variables.title = "Button";
	variables.description = "Display a navigation button and optional label";
	variables.defaults = {
		"title"="Untitled",
		"content"="",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);

		this.classes = "button";
		
		variables.static_css = {
			"navbuttons"=1
		};
		variables.static_js = {
			"autoButton"=1
		};
		this.states = [
			{"state"="main", "selector"="","name":"Main","description":"The main state"},
			{"state"="hover", "selector"=":hover","name":"Hover","description":"The hover state for buttons"}
		];		

		this.selectors = [
			{"name"="main", "selector"=".button"},
			{"name"="label", "selector"=" label"},
			{"name"="icon", "selector"=" .icon"}
		];

		this.styleDefs = [
			"label-align":{"type":"halign","default":"left","description":"text alignment of label."},
			"label-display" = {"type":"list","options"=[{"value":"block","display"="Yes"},{"value":"none","display"="No"}],"default":"block"},
			"icon-display" = {"type":"list","options"=[{"value":"block","display"="Yes"},{"value":"none","display"="No"}],"default":"block"},
			"shape" = {"type":"text"},
			"label-gap" = {"type":"dimension"},
			"button-direction" = {"name":"Label alignment","description":"Show the label on the left or right of the button","type":"list","options"=[{"value":"row", "display":"Right"},{"value":"row-reverse", "display":"Left"}],"default":"row"},
			"button-align" = {"name":"Button alignment","description":"Align button in container","type":"list","options"=[{"value":"flex-start"},{"value":"center"},{"value":"flex-end"}],"default":"center"},
			"link-color" = {"type":"color"},
			"link-color" = {"type":"color"},
			"icon-width" = {"type":"dimension"},
			"icon-height" = {"type":"dimension"},
			"auto" = {"type":"boolean","default": false,"name":"Auto open target","description":"function WIP. Calls open method on target specified in link."}
		];

		this.settings = {
			"shape" = "left_arrow",
			"auto" = false
		}

		variables.shapes = {};

		this.panels = [
			{"name":"label","panel":"label", "selector": " label"},
			{"name":"icon","panel":"icon", "selector": " .icon"}
		];

		return this;
	}

	/**
	 * @hint Add a single shape definition
	 *
	 * Usage of this function is discouraged. Use a single XML definition file and call addShapes()
	 * 
	 * @id   Unique id to reference by. IMPORTANT see notes on usage must also be the ID of the main svg tag
	 * @src    URL of SVG file. 
	 * @viewbox  Copy of viewbox attribute from SVG file
	 */
	public void function addShape(required string id, required string src, required string viewbox) {
		variables.shapes[arguments.id] = {"src"=arguments.src, "viewbox"=arguments.viewbox};
	}

	/**
	 * Add list of shapes
	 * 
	 * @shapeList Array of shape structs with id, src, and viewbox
	 */
	public void function addShapes(required array shapeList) {
		for (local.shape in arguments.shapeList) {
			variables.shapes[local.shape.id] = {"src"=local.shape.src, "viewbox"=local.shape.viewbox};
		}
	}

	public struct function getShapes() {
		return variables.shapes;
	}

	public string function displayShape(required string id) {
		
		if (! StructKeyExists(variables.shapes, arguments.id)) {
			throw(message="Shape #arguments.id# not found",detail="To reference a shape by name it must first be defined in the component via addShape or addShapes");
		}

		local.shape = variables.shapes[arguments.id];
		var html = "<svg class=""icon"" xmlns=""http://www.w3.org/2000/svg"" viewBox=""#local.shape.viewBox#"" preserveAspectRatio=""none""><use href=""#local.shape.src####arguments.id#""/></svg>";

		return html;

	}

	public string function html(required struct content) {
		
		local.Link = StructKeyExists(arguments.content,"link") ? arguments.content.link : "##";

		var linkStart = "<a href='#local.Link#'>";
		var linkEnd = "</a>";
		var cshtml = linkStart;

		// TO DO: check this is handle by the settings and remove
		local.shape = StructKeyExists(arguments.content.settings.main,"shape") ? arguments.content.settings.main.shape : "left_arrow";
		
		cshtml &= displayShape(local.shape);

		if (StructKeyExists( arguments.content,"content") AND  arguments.content.content !="") {
			cshtml &= "<label>#arguments.content.content#</label>";
		}
		
		cshtml &= linkEnd;

		return cshtml;

	}

	public string function onready(required struct content) {
		
		if (arguments.content.settings.main.auto) {
			local.js = "$(""###arguments.content.id#"").button();\n";
		}
		else {
			local.js = "";
		}

		return local.js;
	}

	public string function getClasses(required struct content) {
		var classList = this.classes;
		if (arguments.content.settings.main.auto) {
			classList = listAppend(classList, "auto"," ");
		}
		return classList;
	}

}