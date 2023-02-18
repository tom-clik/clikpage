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
	 * @charset      Charset of text files
	 */
	layouts function init(required string layoutBase, string charset="utf-8") {	

		variables.charset = arguments.charset

		try {
			this.coldsoup = new coldsoup.coldSoup();
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Unable to create coldSoup component. Please refer to set up guide to install and test coldsoup and jsoup:" & e.message, 
				detail       = e.detail,
				errorcode    = "clikpage.layouts.init.1"		
			);
		}

		variables.layoutBase = arguments.layoutBase;
		// remove trailing slash
		variables.layoutBase = ReReplace(variables.layoutBase,"[\\\/]$","");
		
		if (! DirectoryExists(variables.layoutBase)) {
			throw(
				message      = "base path for layouts [#variables.layoutBase#] not found", 
				errorcode    = "clikpage.layouts.init.2"		
			);
		}
		
		this.cacheClear();

		return this;

	}
	
	public void function cacheClear() {
		variables.cache = {};
		variables.cache.layouts = {};
		variables.cache.html = {};
	}

	public struct function loadAll() {

		this.cacheClear();

		var data = {
			"layouts" = [=],
			"content" = {},
			"containers" = {}
		};

		local.list = directoryList(variables.layoutBase,true,"query","*.html");
		
		local.base = ArrayToList(ListToArray(variables.layoutBase,"\/"),".");
		for (local.filedata in list) {
			local.dir = ArrayToList(ListToArray(local.filedata.directory,"\/"),".");
			
			if (local.dir neq local.base) {
				local.subfolder = replace(local.dir, local.base & ".", "") & ".";
			}
			else {
				local.subfolder = "";
			}

			local.id = local.subfolder & ListFirst(local.filedata.name,".");

			data.layouts[local.id] = 1;
			local.layout = getLayout(local.id);
			StructAppend(data.content,local.layout.content);
			StructAppend(data.containers,local.layout.containers);
		}

		return data;

	}

	/**
	 * @hint return layout struct
	 *
	 * @id    ID of layout to load (paths should be dot paths.)
	 *
	 */
	public struct function getLayout(required string id) {

		local.layout = duplicate( loadLayout(arguments.id), true);
		local.layout.layout = variables.cache.layouts[arguments.id].layout.clone();

		return local.layout;

	}

	/**
	 * @hint load layout from file and process
	 *
	 * Caches response but you must always use getLayout if you want to use the returned
	 * value in any way.
	 *
	 */
	private struct function loadLayout(required string id) {
		if (! StructKeyExists(variables.cache.layouts, arguments.id)) {

			local.filename = variables.layoutBase & "/" & Replace(arguments.id,".","/","all") & ".html";
			
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

			local.styling = local.layoutObj["layout"].select("styling");
			
			if (IsDefined("local.styling") AND ArrayLen(local.styling)) {
				local.layoutObj["styles"] = this.coldsoup.XMLNode2Struct(local.styling.first());
			}

			// data attributes
			local.body = this.coldsoup.XMLNode2Struct(local.layoutObj.layout.select("body").first());
			
			if (StructKeyExists(local.body,"data")) {
				if (StructKeyExists(local.body.data,"extends")) {
					local.layoutObj["extends"] = local.body.data.extends;
					extendLayout(local.layoutObj, local.body.data.extends);		
				}
				
			}

			parseContainers(local.layoutObj);
			parseContentSections(local.layoutObj);

			variables.cache.layouts[arguments.id] = local.layoutObj;

			variables.cache.layouts[arguments.id]["bodyClass"] = bodyClass(arguments.id);
			

		}

		return variables.cache.layouts[arguments.id];
		
	}

	public string function getHTML(required layoutObj) {

		addInners(arguments.layoutObj);

		local.test = arguments.layoutObj.layout.select("content");
		
		for (local.div in local.test) {
			local.div.tagName("div");
		}

		return arguments.layoutObj.layout.body().html();

	}

	/** Extend layout with values from "parent" */
	private void function extendLayout(required layout, required string extends) {
		
		local.extends = getLayout(arguments.extends);
		local.parentlayout = local.extends.layout;
		// start by cloning the parent
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
		for (local.node in arguments.layout.layout.select("body > div:not(.inner)")) {
			local.div =  this.coldsoup.XMLNode2Struct(local.node);
			local.existingNode = local.newLayout.select("##" & local.div.id);
			if (ArrayLen(local.existingNode)) {
				local.existingNode.html(local.node.html());
			}
			else {
				local.newLayout.body().append(local.node);
			}
		}

		
		
		arguments.layout.layout = local.newLayout;

	}

	/** 
	 * @hint parse any content tags into structs of data
	 *
	 * 	Every tag or attribute is added as a struck key. Data attributes are added to a data struct. 
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


	/**
	 * @hint parse any content tags into structs of data
	 *
	 * Every tag or attribute is added as a struck key. Data attributes are added to a data struct.
	 *
	 **/
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
						local.cs["type"] = "item";
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
	public void function addInners(required layoutObj) {
		// add inners
		local.divs = [];
		local.test = arguments.layoutObj.layout.select("div");
		
		for (local.div in local.test) {
			if (local.div.id() != "") {
				arrayAppend(local.divs, local.div.id());
			}
		}
		
		for (local.div in local.divs) {
			local.node = arguments.layoutObj.layout.select("###local.div#");
			local.node.html("<div class='inner'>" & local.node.html() & "</div>");
		}
			
	}

	/**
	 * @hint Generate css class name for body
	 *
	 * 
	 */
	public string function bodyClass(required string id) {
		
		var classes = {};
		derivedBodyClass(arguments.id,classes);

		local.names = "";
		for (local.layout in classes) {
			local.names = listAppend(local.names, "template-" & local.layout, " ");
		}

		return local.names;
	}

	private void function derivedBodyClass(required string id, required struct classes) {
		
		arguments.classes[arguments.id]= 1;

		local.layout = loadLayout(arguments.id);
		if (structKeyExists(local.layout, "extends")) {
			derivedBodyClass(local.layout.extends,arguments.classes);
		}

	}

}