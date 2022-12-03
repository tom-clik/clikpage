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
		"content"="Undefined content",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		
		variables.static_css = {
			"navbuttons"=1
		}
		this.settings = {
			"button" = {
				"showlabel" = 1,
				"align" = "left"
			}
		}
		
		variables.shapes = {};

		this.panels = [
			{"name":"item","panel":"item", "selector": " a"},
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
		
		// TO DO: broken
		local.shape = "left_arrow";
		
		// local.shape = StructKeyExists(arguments.content.settings.button,"shape") ? arguments.content.settings.button.shape : "left_arrow";
		cshtml &= "<div class='icon'>" & displayShape(local.shape) & "</div>";

		if (arguments.content.content !="") {
			cshtml &= "<label>#arguments.content.content#</label>";
		}
		
		cshtml &= linkEnd;

		return cshtml;

	}


}