component accessors="true" extends="utils.baseutils" {

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
		
		super.utils();

		variables.pattern = variables.utils.patternObj.compile("\{+[\w\.]+?\}+" ,variables.utils.patternObj.MULTILINE + variables.utils.patternObj.CASE_INSENSITIVE);

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

		local.xmlData = variables.utils.utils.fnReadXML(arguments.filename,"utf-8");
		local.site = variables.utils.XML.xml2data(local.xmlData);
		
		local.site["mode"] = getmode();

		if (NOT StructKeyExists(local.site,"layout")) {
			throw("No layout defined for site");
		}

		// load sections
		parseData(site=local.site,data=local.site.sections,type="sections");

		// load other data from files
		loadData(site=local.site,directory=getDirectoryFromPath(arguments.filename));

		return local.site;

	}

	/** Load data files specified in site.data  */
	private void function loadData(required struct site, required string directory) {
		
		for (local.data in arguments.site.data) {
			if (!StructKeyExists(local.data,"src")) {
				throw(message="No src defined for data entry", detail="Each data record in a site definition must have an src tag pointing to a valid xml data file");	
			}
			local.filepath = arguments.directory & local.data.src;
			try {
				local.xmlData = variables.utils.utils.fnReadXML(local.filepath,"utf-8");
				local.records = variables.utils.xml.xml2data(local.xmlData);
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

		structDelete(arguments.site,"data");

	}

	/** Convert XML parsed array into struct keyed by code 
	 * @site Site struct
	 * @data Array of data records
	 * @type Data type (key from site.data)
	 */
	private void function parseData(required struct site, required array data, required string type) {
		
		arguments.site[arguments.type] = [=];

		for (local.data in arguments.data) {
			
			switch(arguments.type) {
				case "section":
					StructAppend(arguments.data,{"layout":arguments.site.layout},false);
					break;
			}
			try {
				checkFields(local.data,arguments.type);
			}
			catch (any e) {
				local.extendedinfo = {"data"=local.data,"type"=arguments.type};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Unable to parse record:" & e.message, 
					detail       = e.detail
				);
			}


			arguments.site[arguments.type][local.data.id] = local.data; 
			
		}

	}

	// TODO: formal definition of records with checking, defaults etc
	private void function checkFields(required struct data, string type) {
		
		if (!StructKeyExists(arguments.data,"id")) {
			throw(message="No id defined for data record");
		}
		if (!StructKeyExists(arguments.data,"title")) {
			throw(message="No title defined for record");	
		}

		if (!StructKeyExists(arguments.data,"short_title")) {
			arguments.data["short_title"] = arguments.data.title;	
		}	

		for (local.field in ['detail','description']) {
			if (structKeyExists(arguments.data, local.field)) {
				arguments.data[local.field] = variables.utils.flexmark.toHtml(arguments.data[local.field]);
				
			}
		}

		StructAppend(arguments.data,{"tags":"","detail":"","description":"","live":true,"pubdate":nullValue(),"sort_order":0,"image":""},false);

		if (!isBoolean(arguments.data.live)) {
			throw(message="Live value is not boolean");		
		}
		if (!isNull(arguments.data.pubdate) AND !isDate(arguments.data.pubdate)) {
			throw(message="Invalid value for pubdate");			
		}

		switch(arguments.type) {
			case "section":
				if (!StructKeyExists(arguments.data,"layout")) {
					throw("No layout defined for section #arguments.data.code#");
				}
				break;
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
			local.menu = {"link"="?section=#local.sectioncode#","section"="#local.sectioncode#","title"=local.section.menu_title};
			ArrayAppend(local.menuData,local.menu);
		}

		return local.menuData;

	}

	/**
	 * Get array of data IDs that match data set filter criteria
	 * 
	 * @site         Site struct
	 * @tag          see notes. WIP to be replaced by criteria for search
	 */
	public array function getDataSet(
		required struct site, 
		required struct dataset
		) {

		StructAppend(arguments.dataset,{"tag":"","type":"articles"},false);

		local.data = [];

		if (arguments.dataset.tag eq "") {
			return structKeyArray(arguments.site[arguments.dataset.type]);
		}

		local.ref = arguments.site[arguments.dataset.type];

		for (local.id in local.ref) {
			
			local.record = local.ref[local.id];
			
			if (ListFindNoCase(local.record.tags, arguments.dataset.tag)) {
				ArrayAppend(local.data,local.id);
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
	public array function getRecords(
		required struct site, 
		required array  dataset, 
		required string type="articles"
		) {

		local.data = [];

		for (local.id in arguments.dataset) {
			
			ArrayAppend(local.data,arguments.site[arguments.type][local.id]);

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

		return Duplicate(arguments.site[arguments.type][id]);
		
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
			local.text =  ListFirst(local.tag,"{}");
			local.scope = ListFirst(local.text,".");
			local.field = ListRest(local.text,".");

			local.data = {};
			
			if (local.scope == "link") {
				// todo: action and id
				local.linkParams = listToArray(local.field,".");
				local.val = pageLink(section=local.linkParams[1]);
			}
			else {
				if (local.scope == "site") {
					local.data = arguments.site;				
				}

				else if (local.scope == "section") {
					if (StructKeyExists(arguments.site.sections, arguments.sectioncode)) {
						local.data = arguments.site.sections[arguments.sectioncode];
					}

				}

				else if (local.scope == "record") {
					local.data = arguments.record;
				}

				local.val = getDataValue(local.data,local.field);
			}

			arguments.html = Replace(arguments.html, local.tag, local.val,"all");

		}

		return arguments.html;

	}

	private string function getDataValue(data,field) {
		local.val = "<!-- #arguments.field# not found -->";
		if (ListLen(arguments.field,".") gt 1) {
			local.subscope = ListFirst(arguments.field,".");
			local.subfield = ListRest(arguments.field,".");
			if (StructKeyExists(arguments.data, local.subscope)) {
				local.val = getDataValue(arguments.data[local.subscope],local.subfield);
			}
		}
		else if (StructKeyExists(arguments.data, arguments.field)) {
			local.val  = arguments.data[arguments.field];
		}

		return local.val;
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
			local.link = variables.previewurl & "?section=" & local.sectionStr.id;
			if (arguments.action neq "index") {
				local.link &= "&action=#arguments.action#";
			}
			if (arguments.id neq "") {
				local.link &= "&id=#arguments.id#";
			}

		}
		else {
			local.link = local.sectionStr.id;	
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

		// first stab at dataset functionality. 
		/*
			ok this needs reworking.

			A section can have a dataset and the default dataset for an
			item can be that.
			
			They can also define their data sets themsleves. For a menu,
			this default will not be the section, but a search by a tag
			of the mainmenu.

			We want to cache the results by name. These will be keyed by e.g.
			section_<sectionname> or content_<id>

		 */
		if (StructKeyExists(local.rc.sectionObj,"dataset")) {
			
			local.rc.sectionObj["data"] = getDataSet(site=arguments.site,dataset=local.rc.sectionObj.dataset);
			
			// always gets record -- maybe do something about this
			if (arguments.pageRequest.id eq "") {
				arguments.pageRequest.id = local.rc.sectionObj["data"][1];
			}

			local.rc.record = getRecord(site=arguments.site,id=arguments.pageRequest.id,type=local.type);

			// addPageLinks(record=local.rc.record, dataset=local.rc.sectionObj.data, site=arguments.site,section=arguments.pageRequest.section,action="view",type=local.type);
		}
		else if (arguments.pageRequest.id != "" AND arguments.pageRequest.id != 0) {
			throw(message="section data not defined",detail="You must define a dataset for a section to use the record functionality");
		}
		
		// todo: add as method of content object
		for (var content in local.rc.layout.content) {
			try {
				var csdata = local.rc.layout.content[content];
				
				if (! StructKeyExists(arguments.site.cs, content)) {
					arguments.site.cs[content] =  this.contentObj.new(argumentCollection=csdata);
					//writeDump(cs[content]);
					this.contentObj.settings(content=arguments.site.cs[content],styles=arguments.site.styles.content,media=arguments.site.styles.media);
					
					// hardwired for list types at the minute. what to do???
					// reasonably easy to define data sets but waht about the links
					switch (arguments.site.cs[content].type) {
						case "articlelist":
							arguments.site.cs[content].data = local.rc.sectionObj["data"];
							local.data = arguments.site.articles;
						case "imagegrid":
							arguments.site.cs[content].data = local.rc.sectionObj["data"];
							local.data = arguments.site.images;
							break;
						case "menu":
							arguments.site.cs[content].data = getDataSet(site=arguments.site,dataset={"tag"=content,type="sections"});;
							local.data = arguments.site.sections;
							break;
						
					}

					// if (StructKeyExists(arguments.site.cs[content],["dataset"])) {
					// 	local.set = arguments.site.cs[content]["dataset"];

					// 	if (NOT StructKeyExists(arguments.site.data,local.set.name)) {
					// 		arguments.site.data[local.set.name] = getRecords(site=arguments.site,dataset=local.set, type=local.type);
					// 	}
					// }
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