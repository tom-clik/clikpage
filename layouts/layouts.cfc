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
			}
			
			parseContentSections(local.layoutObj);

			variables.layouts[arguments.layout] = local.layoutObj;

		}

		return variables.layouts[arguments.layout];


	}

	private void function extendLayout(required layout, required string extends) {
		local.extends = getLayout(arguments.extends);
		local.parentlayout = local.extends.layout;
		for (local.node in arguments.layout.layout.select("div")) {
			local.div =  this.coldsoup.XMLNode2Struct(local.node);
			local.parentlayout.select("##" & local.div.id).html(local.node.html());
		}
		arguments.layout.layout = local.parentlayout;

	}

	/** parse any content tags into structs of data

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
				// /** remove non html attributes */
				// for (local.attr in local.cs) {
				// 	if (! StructKeyExists(variables.htmlAttrs,local.attr)) {
				// 		local.contentObj.removeAttr(local.attr);
				// 	}
				// }
				
				arguments.layout["content"][local.cs.id] = local.cs;

			}
		}


	}


}