component accessors="true" {

	property name="cr" type="string" default=newLine();
	property name="debug" type="boolean" default=true;
	property name="previewurl" type="string" default="index.cfm";
	property name="mode" type="string" default="preview";

	public site function init(
		required string layoutsFolder
		         ) {

		this.settingsObj = new clikpage.settings.settings(debug=getdebug());
		
		this.contentObj = new clikpage.content.content(settingsObj=this.settingsObj,debug=getdebug());
		this.layoutsObj = new clikpage.layouts.layouts(arguments.layoutsFolder);
		this.pageObj = new clikpage.page(debug=getdebug());
		
		this.utils = CreateObject("component", "utils.utils");	
		this.utilsXML = CreateObject("component", "utils.xml");	
		local.patternObj = createObject( "java", "java.util.regex.Pattern");
		
		variables.pattern = patternObj.compile("\{\{\w+?\.([\w\.]+)?\}\}" ,local.patternObj.MULTILINE + local.patternObj.CASE_INSENSITIVE);

		
		setmode( checkMode( getmode() )  );
		
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
	public void function setSiteMode(struct site, string mode) {
		arguments.site["mode"] = checkMode(arguments.mode);
	}

	public struct function loadSite(required string filename) {

		if (!FileExists(arguments.filename)) {
			throw("Site definition #arguments.filename# not found");
		}

		local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
		local.site = this.utilsXML.xml2data(local.xmlData);
		
		local.site["mode"] = getmode();

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
				local.records = this.utilsXML.xml2data(local.xmlData);
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
	 * Get array of data IDs that match data set filter criteria
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
	public struct function getRecordSetInfo(required struct site, required any ID, required array dataset) {
		local.info = {};
		local.info["pos"] = ArrayFind(arguments.dataset, arguments.ID);
		if (local.info.pos) {
			local.info["previous"] = (local.info.pos > 1) ? local.info.pos - 1: "";
			local.info["count"] = ArrayLen(arguments.dataset);
			local.info["next"] = (local.info.pos < local.info.count) ? local.info.pos + 1: "";
		}
		else {
			throw("#arguments.ID# not found in dataset");
		}
		return local.info;
	}


	public void function addLinks(required array data, required struct site, required string section, string action="index") {
		
		for (local.article in arguments.data) {
			local.article["link"] = pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = local.article.id)
		}	
	}
	public void function addPageLinks(required struct record, required array dataset, required struct site, required string section, string action="index", string type="articles") {
		var info = getRecordSetInfo(site=arguments.site,dataset=arguments.dataset,id=arguments.record.id);
		

		arguments.record["next_link"] = info.next neq "" ? pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = info.next) : "";

		arguments.record["previous_link"] = info.previous neq "" ? pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = info.previous) : "";
		
		// to do: formal definitio of title 
		local.field = arguments.type eq "images" ? "caption" : "title";
		if (info.next neq "") {
			arguments.record["next_title"] = getRecord(site=arguments.site, ID=info.next, type=arguments.type)[local.field ];
		}

		if (info.previous neq "") {
			arguments.record["previous_title"] = getRecord(site=arguments.site, ID=info.previous, type=arguments.type)[local.field ];
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

	public struct function page(required struct pageRequest, required struct site) {

		var pageContent = this.pageObj.getContent();
		
		local.rc = {};
		local.rc.sectionObj = getSection(site=arguments.site,section=arguments.pageRequest.section);

		// WTF. TO DO: sort this
		arguments.site.sections[arguments.pageRequest.section].location = sectionLocation(site=arguments.site,section=arguments.pageRequest.section);

		pageContent.layoutname = getLayoutName(section=local.rc.sectionObj,action=arguments.pageRequest.action);

		local.rc.layout = this.layoutsObj.getLayout(pageContent.layoutname);

		pageContent.bodyClass =  local.rc.layout.bodyClass;

		arguments.site.cs = {};

		local.rc.record = {};
		
		// todo: add as method of content object
		for (var content in local.rc.layout.content) {
			try {
				var csdata = local.rc.layout.content[content];
				
				arguments.site.cs[content] =  this.contentObj.new(argumentCollection=csdata);
				//writeDump(cs[content]);
				this.contentObj.settings(content=arguments.site.cs[content],styles=arguments.site.styles.content,media=arguments.site.styles.media);
				
				// hack for data
				// TO DO: re do this when we have proper data set functionality
				switch (content) {
					case "mainmenu":case "topmenu":
						arguments.site.cs[content]["data"] = menuData(site=arguments.site,sections=arguments.site.sectionlist);
						break;
					case "footermenu":
						arguments.site.cs[content]["data"] = menuData(site=arguments.site,sections="about,contact,privacy");
						break;
				}

				// first stab at dataset functionality. 
				if (StructKeyExists(local.rc.sectionObj,"dataset")) {
					if (! StructKeyExists(local.rc.sectionObj.dataset,"tag")) {
						throw("tag must be defined for dataset at this time");
					}
					local.type = local.rc.sectionObj.dataset.type ? : "articles";
					local.rc.sectionObj["data"] = getDataSet(site=arguments.site,tag=local.rc.sectionObj.dataset.tag, type=local.type);
					// first stab at data functionality. 
					if (arguments.pageRequest.id != "") {
						local.rc.record = getRecord(site=arguments.site,id=arguments.pageRequest.id,type=local.type);
						
						addPageLinks(record=local.rc.record, dataset=local.rc.sectionObj.data, site=arguments.site,section=arguments.pageRequest.section,action="view",type=local.type);
					}
					

				}
				else if (arguments.pageRequest.id != "" AND arguments.pageRequest.id != 0) {
					throw(message="section data not defined",detail="You must define a dataset for a section to use the record functionality");
				}

				// hardwired for list types at the minute. what to do???
				// reasonably easy to define data sets but waht about the links
				switch (arguments.site.cs[content].type) {
					case "articlelist":
						arguments.site.cs[content]["data"] = getRecords(site=arguments.site,dataset=local.rc.sectionObj.data, type=local.type);
						addLinks(data=arguments.site.cs[content]["data"],site=arguments.site,section=arguments.pageRequest.section,action="view");
						break;
					case "imagegrid":

						arguments.site.cs[content]["data"] = getRecords(site=arguments.site,dataset=local.rc.sectionObj["data"], type=local.type);
						
						addLinks(data=arguments.site.cs[content]["data"],site=arguments.site,section=arguments.pageRequest.section,action="view");
						
						break;
				}
				
				local.tag=local.rc.layout.layout.select("###content#").first();
				
				// TO do: use display method
				// and cache results
				local.tag.html(this.contentObj.html(arguments.site.cs[content]));
				
				local.tag.attr("class",this.contentObj.getClassList(arguments.site.cs[content]));
				
				this.contentObj.addPageContent(pageContent,this.contentObj.getPageContent(arguments.site.cs[content],true));
				
			}

			catch (Any e) {
				writeOutput("<h2>issue with #content#</h2>");
				writeDump(e);
			}

		}
		pageContent.css = this.settingsObj.outputFormat(css=pageContent.css,media=arguments.site.styles.media);

		pageContent.body = this.layoutsObj.getHTML(local.rc.layout);

		pageContent.body = dataReplace(site=arguments.site, html=pageContent.body, sectioncode=arguments.pageRequest.section, record=local.rc.record);
		return pageContent;
	}	
	
}