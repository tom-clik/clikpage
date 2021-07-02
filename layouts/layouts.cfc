/**
 * Singleton component for defining layouts
 *
 * An actual layout has the following keys
 *
 * layout    Jsoup document of parsed html
 * title     Title of the layout
 * meta      Struct of meta data with key and value. NB this is for information and documentation of the layouts and is unlreated to html meta data
 * columns   column layout for standard column grid.
 *
 * 

			
			
 * 
 * 
 */
component name="layouts" {

	layouts function init(string layoutBase, string charset="utf-8") {	

		variables.charset = arguments.charset

		this.coldsoup = createObject( "component", "coldsoup.coldSoup" ).init();
		variables.layoutBase = arguments.layoutBase;
		variables.layoutBase =ReReplace(variables.layoutBase,"[\\\/]$","");
		if (! DirectoryExists(variables.layoutBase)) {
			throw("base path for dlayouts not found");
		}

		variables.htmlAttrs = {
			"class" = 1,
			"id" = 1,
			"data" = 1,
			"title" = 1
		}
		
		variables.layouts = {};
		variables.html = {};

		return this;
	}

	public struct function getLayout(required string layout) {

		if (! StructKeyExists(variables.layouts, arguments.layout)) {
			local.filename = variables.layoutBase & "\" & arguments.layout &".html";
			try {
				local.html = FileRead(local.filename,variables.charset);
			}
			catch (Any e) {
				if (!FileExists(local.filename)) {
					throw("Layout #arguments.layout# not found [#local.filename#]");
				}
				else {
					throw(object=e);
				}
			}
			local.layoutObj = {};

			local.layoutObj["layout"] = this.coldsoup.parse(local.html);

			local.title = local.layoutObj["layout"].select("title").first().text();
			
			if (IsDefined("local.title")) {
				local.layoutObj["title"] = local.title ;
			}

			local.meta = local.layoutObj["layout"].select("meta");
			
			if (IsDefined("local.meta")) {
				for (local.metaTag in local.meta) {
					local.layoutObj[local.metaTag.attr("name")] = local.metaTag.attr("content") ;
				}
			}

			// data attributes
			local.body = this.coldsoup.XMLNode2Struct(local.layoutObj["layout"].select("body").first());
			
			if (StructKeyExists(local.body,"data")) {
				if (StructKeyExists(local.body.data,"extends")) {
					extendLayout(local.layoutObj, local.body.data.extends);		
				}
				if (StructKeyExists(local.body.data,"columns")) {
					local.layoutObj["columns"] = local.body.data.columns;		
				}
			}
			
			// local.layoutObj["layout"].select("div[id]").addClass("container");

			parseContentSections(local.layoutObj);

			variables.layouts[arguments.layout] = local.layoutObj;

		}

		return variables.layouts[arguments.layout];

	}

	public string function getHTML(required layoutObj) {

		addInners(arguments.layoutObj);

		return arguments.layoutObj.body().html();

	}

	/** Extend layout with values from "parent" */
	private void function extendLayout(required layout, required string extends) {
		local.extends = getLayout(arguments.extends);
		local.parentlayout = local.extends.layout;
		for (local.node in arguments.layout.layout.select("div")) {
			local.div =  this.coldsoup.XMLNode2Struct(local.node);
			local.parentlayout.select("##" & local.div.id).html(local.node.html());
		}
		if (StructKeyExists(local.extends,"columns") && ! StructKeyExists(arguments.layout,"columns")) {
			arguments.layout.columns = local.extends.columns;
		}
		
		arguments.layout.layout = local.parentlayout;

	}

	/** @hint parse any content tags into structs of data

	Every tag or attribute is added as a struck key. Data attributes are added to a data struct.
	
	*/
	private void function parseContentSections(required struct layout) {
		
		if (! StructKeyExists(arguments.layout,"content")) {
			arguments.layout["content"] = {};
		}
		local.content = arguments.layout.layout.select("content[id]");
		if (IsDefined("local.content")) {
			for (local.contentObj in local.content) {
				
				local.cs = this.coldsoup.XMLNode2Struct(local.contentObj);
				
				if (! StructKeyExists(local.cs,"id")) {
					throw("ID not found for cs #local.contentObj.html()#");
				}
				
				// // convert class attribute to struct
				// if (StructKeyExists(local.cs, "class")) {
				// 	local.tmpClass = {};
				// 	for (local.className in ListToArray(local.cs.class," ")) {
				// 		local.tmpClass[local.className] = 1;
				// 	}
				// 	local.cs.class = local.tmpClass;
				// }

				arguments.layout["content"][local.cs.id] = local.cs;

			}
		}

	}

	/** inner divs applied to children of uberContainer */
	private void function addInners(required layoutObj) {
		// inner divs applied to children of uberContainer
		// if you don't want this, don't use uberContainer...
		local.test = arguments.layoutObj.select("##uberContainer > div");
		for (local.temp in local.test) {
			local.temp.html("<div class='inner'>" & local.temp.html() & "</div>");
			// writeDump(local.test2.outerHtml());
			// writeOutput(htmlEditFormat(local.temp.outerHtml()));
			//wrap("<div class='inner'></div>")
		}
			
	}

}