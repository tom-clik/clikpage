/**
 * Button definition
 *
 * We do not use fonts for button definitions. Instead we use SVG files. Any icon font 
 * will have SVG equivalents to download and use.
 *
 * To allow use of external images, the following mechanism is required to apply CSS styling
 *
 * 1. An id must be applied to the actual svg definition you want to use, e.g.
 * 
 * <svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 viewBox="0 0 197.4 197.4" preserveAspectRatio="none" xml:space="preserve" ><g id="left_arrow"><polygon points="146.88 197.4 45.26 98.7 146.88 0 152.15 5.42 56.11 98.7 152.15 191.98"/></g></svg>
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
 */


component extends="contentSection" {
	function init(required contentObj contentObj) {
		
		super.init(arguments.contentObj);
		variables.type = "button";
		variables.title = "Button";
		variables.description = "Display a navigation button and optional label";
		variables.defaults = {
			"title"="Untitled",
			"content"="Undefined content",
		};
		variables.static_css = {
			"navbuttons"=1
		}
		variables.settings = {
			"button" = {
				"showlabel" = 1,
				"align" = "left"
			}
		}
		
		variables.shapes = {};

		variables.panels = [
			{"name":"item", "selector": " a"},
			{"name":"icon", "selector": " .icon"}
		];

		return this;
	}

	/**
	 * @hint Add a single shape definition
	 *
	 * Usage of this function is doscouraged. Use a single XML definition file and call addShapes()
	 * 
	 * @id   Unique id to reference by. IMPORTANT see notes on usage must also be the ID of the main svg tag
	 * @src    URL of SVG file. All 
	 * @viewbox  Copy of viewbox atteibute from SVG file
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

	public string function displayShape(required string id) {
		
		if (! StructKeyExists(variables.shapes, arguments.id)) {
			throw(message="Shape #arguments.id# not found",detail="To reference a shape by name it must first be defined in the component via addShape or addShapes");

		}

		local.shape = variables.shapes[arguments.id];
		var html = "<svg  xmlns=""http://www.w3.org/2000/svg"" viewBox=""#local.shape.viewBox#"" preserveAspectRatio=""none""><use href=""#local.shape.src####arguments.id#""/></svg>";

		return html;

	}


	public string function html(required struct content) {
		
		local.hasLink = StructKeyExists(arguments.content,"link");

		var linkStart = (local.hasLink) ? "<a href='#arguments.content.link#' title='#ListFirst(arguments.content.link,"{}")#'>" : "";

		var linkEnd = (local.hasLink) ? "</a>" : "";

		var cshtml = "";

		cshtml &= linkStart;
		
		local.shape = StructKeyExists(arguments.content.settings.main.button,"shape") ? arguments.content.settings.main.button.shape : "left_arrow";
		cshtml &= "<div class='icon'>" & displayShape(local.shape) & "</div>";

		if (arguments.content.settings.main.button.showLabel && arguments.content.content !="") {
			cshtml &= "<label>#arguments.content.content#</label>";
		}

		arguments.content.class["demo"] = 1;
		arguments.content.class[arguments.content.settings.main.button.align] = 1;

		cshtml &= linkEnd;

		return cshtml;

	}


}