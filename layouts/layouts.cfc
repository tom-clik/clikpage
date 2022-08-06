/**
 * Singleton component for defining layouts
 *
 * ## Layout definition
 *
 * Layouts are defined as html files. They can inherit from other files (tbc logic)
 *
 * ## Layout struct
 * 
 * An actual layout has the following keys
 *
 * layout    Jsoup document of parsed html
 * title     Title of the layout
 * meta      Struct of meta data with key and value. NB this is for information and documentation of the layouts and is unrelated to html meta data
 * columns   column layout for standard column grid.
 * content   struct of content items keyed by id
 * containers   struct of containers
 * 
 *  ## Cache
 *
 * 
 * 
 */

component name="layouts" {

	/**
	 * Pseudo contstructor 
	 * @layoutBase   Path to folder container layouts
	 * @charset      Charset to text files
	 */
	layouts function init(required string layoutBase, string charset="utf-8") {	

		variables.charset = arguments.charset

		try {
			this.coldsoup = new coldsoup.coldSoup();
		}
		catch (Any e) {
			throw(message="Unable to create coldSoup component. Please refer to set up guide to install and test coldsoup and jsoup.",detail="#e.message#<br><br>#e.detail#")
		}

		variables.layoutBase = arguments.layoutBase;
		variables.layoutBase =ReReplace(variables.layoutBase,"[\\\/]$","");
		
		if (! DirectoryExists(variables.layoutBase)) {
			throw("base path for layouts [#variables.layoutBase#] not found");
		}

		// "set" of html attributes to parse from layout.
		// variables.htmlAttrs = {
		// 	"class" = 1,
		// 	"id" = 1,
		// 	"data" = 1,
		// 	"title" = 1
		// }
		
		variables.cache = {};
		variables.cache.layouts = {};
		variables.cache.html = {};

		return this;

	}

	/**
	 * @hint return layout struct
	 *
	 * 
	 * @id    ID of layout to load (relative path of layout without file extension)
	 *
	 * 
	 */
	public struct function getLayout(required string id) {

		if (! StructKeyExists(variables.cache.layouts, arguments.id)) {
			local.filename = variables.layoutBase & "\" & arguments.id &".html";
			
			if (!FileExists(local.filename)) {
				throw("Layout #arguments.id# not found [#local.filename#,#variables.layoutBase#,#arguments.id#]");
			}

			local.html = FileRead(local.filename,variables.charset);
			
			local.layoutObj = {"id"=arguments.id};

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
					local.layoutObj.layout.body().removeAttr("data-columns")	;
				}
			}

			// local.layoutObj["layout"].select("div[id]").addClass("container");
			parseContainers(local.layoutObj);
			parseContentSections(local.layoutObj);

			variables.cache.layouts[arguments.id] = local.layoutObj;

		}

		return variables.cache.layouts[arguments.id];

	}

	public string function getHTML(required layoutObj) {

		addInners(arguments.layoutObj);

		return arguments.layoutObj.body().html();

	}

	/** Extend layout with values from "parent" */
	private void function extendLayout(required layout, required string extends) {
		local.extends = getLayout(arguments.extends);
		local.parentlayout = local.extends.layout;
		local.newLayout = local.extends.layout.clone();

		local.newLayout.title(arguments.layout.layout.title());

		// update meta data in parent layout.
		local.metaData = {};
		for (local.meta in arguments.layout.layout.select("meta")) {
			local.metaData[local.meta.attr("name")] = local.meta.attr("content");
		}

		for (local.meta in local.newLayout.select("meta")) {
			if (StructKeyExists(local.metaData,local.meta.attr("name"))) {
				local.meta.attr("content",local.metaData[local.meta.attr("name")]);
				StructDelete(local.metaData,local.meta.attr("name"));
			}
		}
		for (local.meta in local.metaData) {
			doc.head().appendElement("meta").attr("name",local.meta).attr("content",local.metaData[local.meta]);
		}

		// Extend all nodes 
		for (local.node in arguments.layout.layout.select("div:not(.inner)")) {
			local.div =  this.coldsoup.XMLNode2Struct(local.node);
			local.newLayout.select("##" & local.div.id).html(local.node.html());
		}

		// other data
		if (StructKeyExists(local.extends,"columns") && ! StructKeyExists(arguments.layout,"columns")) {
			arguments.layout["columns"] = local.extends.columns;
		}
		
		arguments.layout.layout = local.newLayout;

	}

	/** @hint parse any content tags into structs of data

	Every tag or attribute is added as a struck key. Data attributes are added to a data struct.
	
	*/
	private void function parseContainers(required struct layout) {
		
		if (! StructKeyExists(arguments.layout,"containers")) {
			arguments.layout["containers"] = {};
		}
		local.containers = arguments.layout.layout.select("div[id]");
		
		if (IsDefined("local.containers")) {
			for (local.containerObj in local.containers) {
				local.cs = this.coldsoup.getAttributes(local.containerObj);
				
				arguments.layout["containers"][local.cs.id] = local.cs;

			}
		}

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
				// by default any cs with a title will be a general cs
				if (! StructKeyExists(local.cs, "type")) {
					if (StructKeyExists(local.cs, "title")) {
						local.cs["type"] = "general";
					}
					else {
						local.cs["type"] = "text";
					}
				}
				
				// link tags defined as href as link can't be used in html definition (jsoup mangles it)
				// to do: make decision on this. convert everything to href?
				if (StructKeyExists(local.cs, "href")) {
					local.cs["link"] = local.cs.href;
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

	/** inner divs applied to children of uberContainer 
	
	TO DO: biggest outstanding question is what to do about inners
	Do we only add them if they are spanning? If so how o we know whether to apply e.g. grid settings
	to the inners

	*/
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