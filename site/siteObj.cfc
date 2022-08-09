component  accessors="true" {

	property name="cr" type="string" default="#chr(13)##chr(10)#";
	property name="debug" type="boolean" default=false;
	property name="previewurl" type="string" default="index.cfm";
	property name="mode" type="string" default="preview";

	public siteObj function init(string mode="preview") {

		this.utils = CreateObject("component", "clikpage.utils.utilsold");	
		local.patternObj = createObject( "java", "java.util.regex.Pattern");
		
		variables.pattern = patternObj.compile("\{\{\w+?\.([\w\.]+)?\}\}" ,local.patternObj.MULTILINE + local.patternObj.CASE_INSENSITIVE);

		variables.mode = checkMode(arguments.mode);

		return this;
	}

	/** 
	 * @hint Set default site mode for object
	 *
	 */
	public string function checkMode(string mode) {
		switch (arguments.mode) {
			case "preview": case "cache": 
				
			break;
			default:
				throw(message="Invalid site object mode #arguments.mode#",detail="Site mode must be preview or cache");
		}
		return arguments.mode;
	}

	/** 
	 * @hint Set site mode for site
	 *
	 */
	public void function setMode(struct site, string mode) {
		arguments.site["mode"] = checkMode(arguments.mode);
	}

	public struct function loadSite(required string filename) {

		if (!FileExists(arguments.filename)) {
			throw("Site definition #arguments.filename# not found");
		}

		local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
		local.site = this.utils.xml2data(local.xmlData);
		
		local.site["mode"] = variables.mode;

		parseSections(local.site);
		loadData(site=local.site,directory=getDirectoryFromPath(arguments.filename));

		return local.site;

	}

	/** Convert XML parsed array into struct keyed by code and append to an array list to keep a record of the order  */
	private void function parseSections(required struct site) {
		
		local.sectionStr = {};

		local.sectionArray = [];

		for (local.section in arguments.site.sections) {
			
			if (!StructKeyExists(local.section,"code")) {
				throw(message="No code defined for section");
			}
			if (!StructKeyExists(local.section,"title")) {
				throw(message="No title defined for section");	
			}	

			local.sectionStr[local.section.code] = local.section; 
			ArrayAppend(local.sectionArray,local.section.code);

			if (!StructKeyExists(local.section,"layout")) {
				if (StructKeyExists(arguments.site,"layout")) {
					local.section["layout"] = 	arguments.site.layout; 
				}
				else {
					throw("No layout defined for section #local.section.code#");
				}
			}

		}

		arguments.site["sections"] = local.sectionStr;
		arguments.site["sectionlist"] = local.sectionArray ;

	}

	/** Convert XML parsed array into struct keyed by code  */
	private void function loadData(required struct site, required string directory) {
		local.dataFiles = Duplicate(arguments.site.data);
		arguments.site["data"] = {};

		for (local.data in local.dataFiles) {
			if (!StructKeyExists(local.data,"src")) {
				throw(message="No src defined for data entry", detail="Each data record in a site definition must have an src tag pointing to a valid xml data file");	
			}
			local.filepath = arguments.directory & local.data.src;
			try {
				local.xmlData = this.utils.fnReadXML(local.filepath,"utf-8");
				local.records = this.utils.xml2data(local.xmlData);
				if (NOT IsArray(local.records)) {
					throw("Data is not array");
				}
				if (NOT StructKeyExists(local.data,"type")) {
					local.data.type = "articles";
				}
				parseData(site=arguments.site,data=local.records,type=local.data.type);
			}
			catch (any e) {
				if (e.type eq "filenotfound") {
					throw(message="Data file #local.filepath# not found");	
				}
				local.extendedinfo = {"tagcontext"=e.tagcontext};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Unable to parse data file #local.filepath#:" & e.message, 
					detail       = e.detail,
					errorcode    = "loadData.2"		
				);
			}
		}
	}

	/** Convert XML parsed array into struct keyed by code 
	 * @site Site struct
	 * @data Array of data records
	 * @type Data type (key from site.data)
	 */
	private void function parseData(required struct site, required array data, required string type) {
		
		if (! StructKeyExists(arguments.site["data"],arguments.type)) {
			arguments.site["data"][arguments.type] = [=];
		}

		for (local.data in arguments.data) {
			
			if (!StructKeyExists(local.data,"id")) {
				throw(message="No id defined for data record",detail="Each data record must have an id property");	
			}

			arguments.site["data"][arguments.type][local.data.id] = local.data; 
			
		}

	}

	/**
	 * Get array of data for using in menu components
	 * 
	 * @site         Site struct
	 * @sections     Array or list of section codes
	 */
	public array function menuData(required struct site, required sections) {

		if (! isArray(arguments.sections)) {
			arguments.sections = listToArray(arguments.sections);
		}

		local.menuData = [];
		for (local.sectioncode in arguments.sections) {
			local.section = arguments.site.sections[local.sectioncode];
			local.menu = {"link"="?section=#local.sectioncode#","section"="#local.sectioncode#","title"=local.section.title};
			ArrayAppend(local.menuData,local.menu);
		}

		return local.menuData;

	}

	/**
	 * Get array od data IDs that match data set filter criteria
	 * 
	 * @site         Site struct
	 * @tag          see notes. WIP to be replaced by creiteria for search
	 */
	public array function getDataSet(required struct site, required string tag, required string type="articles") {
		// temp solution
		// the idea is that we will define the data types in XML 
		// and allow for dynamic parsing
		// TODO: dynamic data parsing
		// 
		local.data = [];

		for (local.id in arguments.site.data[arguments.type]) {
			local.record = arguments.site.data[arguments.type][local.id];
			
			if (ListFindNoCase(local.record.tags, arguments.tag)) {
				ArrayAppend(local.data,local.record.id);
			}
		}

		return local.data;

	}

	/**
	 * Get array of data to supply to content objects
	 * 
	 * @site   Site struct
	 * @dataSet     array of IDs (see getDataSet())
	 * @type data type
	 */
	public array function getRecords(required struct site, required array dataset, required string type="articles") {

		local.data = [];

		for (local.id in arguments.dataset) {
			local.article = arguments.site.data[arguments.type][local.id];
			local.articledata = {"id"=local.id};
			switch(arguments.type) {
				case "articles":
					local.articledata["title"] = local.article.title;
					local.articledata["content"] = StructKeyExists(local.article,"strapline") ? local.article.strapline : (StructKeyExists(local.article,"intro") ? local.article.intro : "");
					local.articledata[" ?"] = local.article.title;
					if (local.article.image neq "") {
						local.articledata["image"] = "/images/" & local.article.image;
					}
					if (local.article.caption neq "") {
						local.articledata["caption"] = local.article.caption;
					}
				break;
				case "images":
					// TO DO: image paths
					local.articledata["src"] = "/images/" & local.article.image_thumbnail;
					if (local.article.caption neq "") {
						local.articledata["caption"] = local.article.caption;
					}
				break;
			}
			ArrayAppend(local.data,local.articledata);
		}

		return local.data;

		
		
	}

	/**
	 * Get full record of data
	 * 
	 * @site   Site struct
	 * @dataSet     array of IDs (see getDataSet())
	 * @type data type
	 */
	public struct function getRecord(required struct site, required any ID, required string type="articles") {

		return Duplicate(arguments.site.data[arguments.type][id]);
		
	}

	/**
	 * Get previous/next record info for a given id in a dataset
	 * 
	 * @site   Site struct
	 * @ID   
	 * @dataSet     array of tags (see getDataSet())
	 * @type data type
	 */
	public struct function getRecordSetInfo(required struct site, required any ID, required array dataset, string type="articles") {
		local.info = {};
		local.info["pos"] = ArrayFind(arguments.dataset, arguments.ID);
		if (local.info.pos) {
			local.info["previous"] = (local.info.pos > 1) ? local.info.pos - 1: "";
			local.info["count"] = ArrayLen(arguments.dataset);
			local.info["next"] = (local.info.pos < local.info.count) ? local.info.pos + 1: "";
		}
		return local.info;
	}


	public void function addLinks(required array data, required struct site, required string section, string action="index") {

		for (local.article in arguments.data) {
			local.article["link"] = pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = local.article.id)
		}	
	}


	public string function dataReplace(required struct site, required string html, required string sectioncode, string action="index", string id="", struct record={}) {

		local.tags = variables.pattern.matcher(arguments.html);
		local.tagMatches = {};
		while (local.tags.find()) {
			local.tagMatches[ListFirst(local.tags.group())] = 1;
		}

		for (local.tag in local.tagMatches) {
			local.text = ListFirst(local.tag,"{}");
			local.scope = ListFirst(local.text,".");
			local.field = ListRest(local.text,".");

			local.val = "<!-- #local.scope# #local.field# val not found -->";
			
			if (local.scope == "site") {
				if (ListLen(local.field,".") gt 1) {
					local.subscope = ListFirst(local.field,".");
					local.subfield = ListRest(local.field,".");
					if (StructKeyExists(arguments.site, local.subscope)) {
						if (StructKeyExists(arguments.site[local.subscope],local.subfield )) {
							local.val  = arguments.site[local.subscope][local.subfield];
						}
					}
				}
				else if (StructKeyExists(arguments.site, local.field)) {
					local.val  = arguments.site[local.field];
				}
				
			}

			else if (local.scope == "section") {
				if (StructKeyExists(arguments.site.sections, arguments.sectioncode) && StructKeyExists(arguments.site.sections[arguments.sectioncode], local.field)) {
					local.val  =  arguments.site.sections[arguments.sectioncode][local.field];
				}
			}

			else if (local.scope == "record") {
				if (StructKeyExists(arguments.record, local.field)) {
					local.val  =  arguments.record[local.field];
				}
			}

			arguments.html = Replace(arguments.html, local.tag, local.val,"all");

		}

		return arguments.html;

	}

	public struct function getSection(required struct site, required string section) {
		if (! StructKeyExists(arguments.site.sections,arguments.section)) {
			throw(message="Section #arguments.section# not found",type="notfound");
		}
		return arguments.site.sections[arguments.section];

	}


	/**
	 * HTML breadcrumbs for location
	 * 
	 * @site    Site struct
	 * @section section code of current section
	 *
	 */
	public string function sectionLocation(required struct site, required string section) {

		local.sectionStr = getSection(site=arguments.site,section=arguments.section);
		local.homeSectionStr = getSection(site=arguments.site,section="index");

		var html = "<a href='" & pageLink(site=arguments.site,section="index") & "'>" & local.homeSectionStr.title & "</a> &gt; ";
		// TO DO: sub sections. Recursive loop
		html &= "<a href='" & pageLink(site=arguments.site,section=arguments.section) & "'>" & local.sectionStr.title & "</a>";

		return html;
	}

	public string function pageLink(required struct site, required string section, string action="index", string id="") {
		local.sectionStr = getSection(site=arguments.site,section=arguments.section);
		if (arguments.site.mode == "preview") {
			local.link = variables.previewurl & "?section=" & local.sectionStr.code;
			if (arguments.action neq "index") {
				local.link &= "&action=#arguments.action#";
			}
			if (arguments.id neq "") {
				local.link &= "&id=#arguments.id#";
			}

		}
		else {
			local.link = local.sectionStr.code;	
			if (arguments.action neq "index") {
				local.link &= "_#arguments.action#";
			}
			if (arguments.id neq "") {
				local.link &= "_#arguments.action#";
			}
			local.link &= ".html";
		}
		
		return local.link;
	}

	/**
	 * @hint Get layout name for a given section and action
	 *
	 * Layout can be a simple value or an array of values if there are different layouts for different actions
	 *
	 * In addtion the array values can be simple (default for section) or a struct if an action is specified.
	 *
	 *  e.g.
	 *  
	 * <section code="news">
			<title>News</title>
			<layout>testlayout5</layout>
			<layout action="detail">testlayout6</layout>
		</section>
	 * 
	 */
	public string function getLayoutName(required struct section, string action="index") {


		if (isSimpleValue(arguments.section.layout)) {
			local.layoutName =  arguments.section.layout;	
		}
		else {
			local.layoutName = ""; 
			local.defaultLayout = ""; 
			for (local.layout in arguments.section.layout) {
				if (isSimpleValue(local.layout)) {
					local.action = "index";
					local.value = local.defaultLayout = local.layout;
				}
				else {
					local.action = StructKeyExists(local.layout,"action") ? local.layout.action: "index";
					local.action = local.layout.action;
					local.value = local.layout.value;
				}
				if (local.action == arguments.action) {
					local.layoutName = local.value;
					break;
				}
			}
			if (local.layoutName =="") {
				if (local.defaultLayout == "") {
					throw(message="No layout defined for action #arguments.action#",detail="Either define a layout for all actions or define a default layout for the section");
				}
				else {
					local.layoutName = local.defaultLayout;
				}
			}
		}

		return local.layoutName;
		
	}

	/**
	 * @hint Generate css class name for body
	 *
	 * 
	 */
	public string function bodyClass(required struct layout) {
		
		local.columnLayout = StructKeyExists(arguments.layout,"columns") ? arguments.layout.columns : "col-S-M-X mid-S-MX mob-SMX ";
		local.spanning = true? " spanning": "";
		// TO DO: MUST DO: inheritance of layout names isn't done!
		return "layout-testlayout layout-#arguments.layout.id# #local.columnLayout#" & local.spanning;
	}

}