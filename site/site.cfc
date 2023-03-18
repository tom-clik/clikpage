component accessors="true" extends="utils.baseutils" {

	property name="cr" type="string" default=newLine();
	property name="debug" type="boolean" default=true;
	property name="previewurl" type="string" default="index.cfm";
	
	public site function init(
		required string layoutsFolder
		) {

		this.settingsObj = new clikpage.settings.settings(debug=getdebug());
		
		this.contentObj = new clikpage.content.content(settingsObj=this.settingsObj,debug=getdebug());
		this.layoutsObj = new clikpage.layouts.layouts(arguments.layoutsFolder);
		this.pageObj = new clikpage.page(debug=getdebug());
		
		super.utils();

		variables.pattern = variables.utils.patternObj.compile("\{+[\w\.]+?\}+" ,variables.utils.patternObj.MULTILINE + variables.utils.patternObj.CASE_INSENSITIVE);

		return this;
	}

	/** 
	 * @hint Set mode for site
	 *
	 */
	public void function setSiteMode(struct site, string mode) {
		switch (arguments.mode) {
			case "preview": case "cache": 
				
			break;
			default:
				throw(message="Invalid site object mode #arguments.mode#",detail="Site mode must be preview or cache");
		}
		arguments.site["mode"] = arguments.mode;
	}

	public struct function loadSite(required string filename) {

		if (!FileExists(arguments.filename)) {
			throw("Site definition #arguments.filename# not found");
		}

		local.xmlData = variables.utils.utils.fnReadXML(arguments.filename,"utf-8");
		local.site = variables.utils.XML.xml2data(local.xmlData);
		
		local.site["mode"] = "preview";

		if (NOT StructKeyExists(local.site,"layout")) {
			throw("No layout defined for site");
		}

		// load sections
		parseData(site=local.site,data=local.site.sections,type="sections");

		// load other data from files
		loadData(site=local.site,directory=getDirectoryFromPath(arguments.filename));

		return local.site;

	}

	/** Load data files specified in site.data 
	 * 
	 *
	 * // TODO: replace directory with explicit links from site def.
	 * // TODO: dumps data keys into root (??) put back into data key
	 */
	private void function loadData(
		required struct site, 
		required string directory
		) {
		
		for (local.data in arguments.site.data) {
			if (!StructKeyExists(local.data,"src")) {
				throw(message="No src defined for data entry", detail="Each data record in a site definition must have an src tag pointing to a valid xml data file");	
			}
			local.filepath = arguments.directory & local.data.src;
			local.image_path = local.data.image_path ? : "";

			try {
				local.xmlData = variables.utils.utils.fnReadXML(local.filepath,"utf-8");
				local.records = variables.utils.xml.xml2data(local.xmlData);
				if (NOT IsArray(local.records)) {
					throw("Data is not array");
				}
				if (NOT StructKeyExists(local.data,"type")) {
					local.data.type = "articles";
				}
				parseData(site=arguments.site,data=local.records,type=local.data.type,image_path=local.image_path);
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
	private void function parseData(required struct site, required array data, required string type, string image_path="") {
		
		arguments.site[arguments.type] = [=];

		for (local.data in arguments.data) {

			switch(arguments.type) {
				case "sections":
					StructAppend(local.data,{"layout":arguments.site.layout},false);
					break;
			}
			try {
				checkFields(data=local.data,type=arguments.type,image_path=arguments.image_path);
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
	private void function checkFields(required struct data, string type, string image_path="") {
		
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
				arguments.data[local.field] = Trim(arguments.data[local.field])	;
			}
		}

		if (arguments.image_path NEQ "" ) {
			for (local.field in ['image','image_thumb']) {
				if (structKeyExists(arguments.data, local.field) AND arguments.data[local.field]  NEQ "" ) {
					arguments.data[local.field] = arguments.image_path & arguments.data[local.field];					
				}
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
			case "sections":
				if (!StructKeyExists(arguments.data,"layout")) {
					throw("No layout defined for section #arguments.data.id#");
				}
				break;
		}
		
	}

	/**
	 * @hint Get array of data for using in menu components
	 *
	 * Use normal dataset functionality to get array of section 
	 * codes. The call this to get menu data.
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
			local.menuitem = {"link"="?section=#local.sectioncode#","id"="#local.sectioncode#","title"=local.section.title};
			if (StructKeyExists(local.section,"dataset")) {
				local.useSubmenu = ListFindNoCase("articles,sections",getDataSetType(local.section.dataset));
				if ( local.useSubmenu ) {
					local.data = getDataSet(site=arguments.site,dataset=local.section.dataset);

					if ( ArrayLen(local.data) GT 1) {
						local.menuitem["submenu"] = [];
						local.records = getRecords(
							site=arguments.site,
							dataset=local.data,
							type=local.section.dataset.type
						);
						for (local.record in local.records) {
							switch (local.section.dataset.type)	{
								case "articles":
									local.link = "{link.#local.sectioncode#.view.#local.record.id#}";
									break;
								case "sections":
									local.link = "{link.#local.record.id#}";
									break;

							}
							local.submenuitem = {"link"="#local.link#","id"="submenu_#local.sectioncode#_#local.record.id#","title"=local.record.title};
							ArrayAppend(local.menuitem.submenu, local.submenuitem);
						}
					}
				}
			}
			ArrayAppend(local.menuData,local.menuitem);
		}

		return local.menuData;

	}


	public string function getDataSetType(
		required struct dataset
		) {
		return dataset.type ? : "articles";
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

		StructAppend(arguments.dataset,{"tag":"","parent":"","type":"articles"},false);

		local.data = [];

		if (arguments.dataset.tag eq "" AND arguments.dataset.parent eq "") {
			return structKeyArray(arguments.site[arguments.dataset.type]);
		}

		local.ref = arguments.site[arguments.dataset.type];

		for (local.id in local.ref) {
			
			local.record = local.ref[local.id];
			if (arguments.dataset.tag neq "") {
				if (ListFindNoCase(local.record.tags, arguments.dataset.tag)) {
					ArrayAppend(local.data,local.id);
				}
			}
			else if (StructKeyExists(local.record,"parent") AND
					local.record.parent eq arguments.dataset.parent) {
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

	/**
	 * wip ADDING LINKS. All this func tbc
	 */
	public void function addLinks(required array data, required struct site, required string section, string action="index") {
		
		for (local.article in arguments.data) {
			local.article["link"] = pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = local.article.id)
		}	
	}
	/**
	 * add links to a single record for next,previous etc
	 */
	public void function addPageLinks(
		required struct record, 
		required array  dataset, 
		required struct site, 
		required string section, 
				 string action="index", 
				 string type="articles"
		) {

		var info = getRecordSetInfo(site=arguments.site,dataset=arguments.dataset,id=arguments.record.id);
		
		arguments.record["next_link"] = info.next neq "" ? pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = info.next) : "";

		arguments.record["previous_link"] = info.previous neq "" ? pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = info.previous) : "";
		
		if (info.next neq "") {
			arguments.record["next_title"] = getRecord(site=arguments.site, ID=info.next, type=arguments.type)["title"];
		}

		if (info.previous neq "") {
			arguments.record["previous_title"] = getRecord(site=arguments.site, ID=info.previous, type=arguments.type)["title"];
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
			local.hasScope = 0;
			local.val = "";
			
			if (local.scope == "site") {
				local.val = getDataValue(arguments.site,local.field);
				local.hasScope = 1;			
			}

			else if (local.scope == "section") {
				if (StructKeyExists(arguments.site.sections, arguments.sectioncode)) {
					local.val = getDataValue(arguments.site.sections[arguments.sectioncode],local.field);
				}
				local.hasScope = 1;	
			}

			else if (local.scope == "record") {
				local.val = getDataValue(arguments.record,local.field);
				local.hasScope = 1;	
			}

			if (local.hasScope)	{
				arguments.html = Replace(arguments.html, local.tag, local.val,"all");
			}

		}

		// do it again for links
		local.tags = variables.pattern.matcher(arguments.html);
		local.tagMatches = {};
		while (local.tags.find()) {
			local.tagMatches[ListFirst(local.tags.group())] = 1;
		}
		
		for ( local.tag in local.tagMatches ) {
			local.text =  ListFirst(local.tag,"{}");
			local.scope = ListFirst(local.text,".");
			local.field = ListRest(local.text,".");	
			if ( local.scope == "link" ) {
				local.linkParams = listToArray(local.field,".");
				local.linkArgs= {
					site=arguments.site,
					section=local.linkParams[1]	
				};
				if ( ArrayLen( local.linkParams ) GT 1 ) {
					local.linkArgs["action"] = local.linkParams[2]	;
				}
				if ( ArrayLen( local.linkParams ) GT 2 ) {
					local.linkArgs["id"] = local.linkParams[3]	;
				}
				local.val = pageLink(argumentcollection=local.linkArgs);
				arguments.html = Replace(arguments.html, local.tag, local.val,"all");
			}
		}
		return arguments.html;

	}

	private string function getDataValue(data,field) {
		local.val = "<!-- field #arguments.field# not found -->";
		
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

	/**
	 * Generate page link according to whether we are in live or cache mode
	 * 
	 * @return {[type]}          [description]
	 */
	private string function pageLink(required struct site, required string section, string action="index", string id="") {
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
	 * In addition the array values can be simple (default for section) or a struct 
	 * if an action is specified.
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
	public string function getLayoutName(
		required struct section, 
				 string action="index",
		required struct site
		) {

		if ( NOT structKeyExists( arguments.section,"layout" ) ) {
			if ( NOT structKeyExists( arguments.site,"layout" ) ) {
				throw(
					message="No layout defined for section #arguments.section.id#",
					detail="If no default site layout is defined, a layout must be specified for all sections."
				);
			}
			else {
				return arguments.site.layout;
			}
		}

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
					throw(
						message="No layout defined for action #arguments.action# in section #arguments.section.id#",
						detail="Either define a layout for all actions or define a default layout for the section");
				}
				else {
					local.layoutName = local.defaultLayout;
				}
			}
		}

		return local.layoutName;
		
	}

	/**
	 * @hint Display a page.
	 *
	 * WIP at the minute. Much needs to be sorted here.
	 * 
	 */
	public struct function page(required struct pageRequest, required struct site) {

		var pageContent = this.pageObj.getContent();
		
		local.rc = {};
		local.rc.sectionObj = getSection(site=arguments.site,section=arguments.pageRequest.section);

		// WTF. TO DO: sort this
		arguments.site.sections[arguments.pageRequest.section].location = sectionLocation(site=arguments.site,section=arguments.pageRequest.section);

		pageContent.layoutname = getLayoutName(section=local.rc.sectionObj,action=arguments.pageRequest.action,site=arguments.site);

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

			local.rc.record = Duplicate(getRecord(site=arguments.site,id=arguments.pageRequest.id,type=local.rc.sectionObj.dataset.type));

			addPageLinks(record=local.rc.record, dataset=local.rc.sectionObj.data, site=arguments.site,section=arguments.pageRequest.section,action="view",type=local.rc.sectionObj.dataset.type);
		}
		else if ( arguments.pageRequest.id != "" ) {
			throw(message="section data not defined",detail="You must define a dataset for a section to use the record functionality");
		}
		
		// todo: add as method of content object
		for (var content in local.rc.layout.content) {
			try {
				var csdata = local.rc.layout.content[content];
				// TODO: remove true
				if (TRUE OR ! StructKeyExists(arguments.site.cs, content)) {
					arguments.site.cs[content] =  this.contentObj.new(argumentCollection=csdata);
					//writeDump(cs[content]);
					this.contentObj.settings(content=arguments.site.cs[content],styles=arguments.site.styles.content,media=arguments.site.styles.media);
					
					local.data = {};
					local.datatype = "sections";
					// hardwired for list types at the minute. what to do???
					// reasonably easy to define data sets but waht about the links
					switch (arguments.site.cs[content].type) {
						case "articlelist":
						case "imagegrid":
							;
							if ( StructKeyExists( arguments.site.cs[content] , "dataset") )  {
								arguments.site.cs[content].data = getDataSet(
									site=arguments.site,
									dataset=arguments.site.cs[content].dataset
								);
								local.datatype = arguments.site.cs[content].dataset.type;
								
			
							}
							else if ( StructKeyExists( local.rc.sectionObj,"dataset" ) ) {
								local.datatype = local.rc.sectionObj.dataset.type;
								arguments.site.cs[content].data = local.rc.sectionObj["data"];
							}
							else {
								throw("No data set defined");
							}

							break;
						case "menu":
							if ( StructKeyExists( arguments.site.cs[content] , "dataset") )  {
								
								local.menuDataSet = getDataSet(
									site=arguments.site,
									dataset=arguments.site.cs[content].dataset
								);
								local.datatype = arguments.site.cs[content].dataset.type;
							}
							else {
								local.menuDataSet = arguments.site.cs[content].data = getDataSet(site=arguments.site,dataset={"tag"=content,type="sections"});
								local.datatype = "sections";
							}
							arguments.site.cs[content].data = menuData(arguments.site,local.menuDataSet);
							
							break;
						
					}

					local.data = arguments.site[local.datatype];

				}
				
				local.tag=local.rc.layout.layout.select("###content#").first();
				
				// TO do: use display method
				// and cache results
				local.tag.html(this.contentObj.html(content=arguments.site.cs[content],data=local.data));
				
				local.tag.attr("class",this.contentObj.getClassList(arguments.site.cs[content]));
				
				this.contentObj.addPageContent(pageContent,this.contentObj.getPageContent(arguments.site.cs[content],local.data));
				
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

	/**
	 * Get a list of all layouts used in the site
	 */
	private array function getSiteLayouts(required struct site) {
		
		// cache results in arguments.site.layouts
		if (NOT StructKeyExists(arguments.site, "layouts")) {

			local.layouts = [=];
			
			// site has a default layout
			if ( StructKeyExists(arguments.site, "layout") ) {
				local.layouts[arguments.site.layout] = 1;
			}
			// See notes on getLayoutName for structure of layouts
			for ( local.section in arguments.site.sections ) {
				if ( StructKeyExists( arguments.site.sections[local.section], "layout" ) ) {
					local.layout = arguments.site.sections[local.section].layout;
					if (isSimpleValue(local.layout)) {
						local.layouts[local.layout] = 1;
					}
					else {
						for (local.layoutAction in local.layout) {
							if (isSimpleValue(local.layoutAction)) {
								local.layouts[local.layoutAction] = 1;
							}
							else {
								local.layouts[local.layoutAction.value] = 1;
							}
						}
					}
					
				}
			}

			arguments.site.layouts = StructKeyArray(local.layouts);

		}
		return arguments.site.layouts;
	}
	
	string function siteCSS(required struct site, required styleSettings) {
	
		var css = "";
		
		css &= ":root {\n";
		css &= this.settingsObj.colorVariablesCSS(arguments.styleSettings);
		css &= this.settingsObj.fontVariablesCSS(arguments.styleSettings);
		css &= this.settingsObj.variablesCSS(arguments.styleSettings);
		css &=  "\n}\n";
		css &= this.settingsObj.CSSCommentHeader("Layouts");
		
		// get list of all layouts.
		local.layouts = getSiteLayouts(arguments.site);
		// complete struct of all cs
		local.content = {};
		// list of all containers used in site
		local.containerList = [=];
		// complete struct of all styles -- need to get schemes
		// WILLDO: additional stylesheets for schemes
		
		local.styles = {};

		// CSS for layouts
		// watch order -- must do in order they appear in stylesheet
		// which must match the precendence for inheritance (known issue)
		// WILLDO: create body classes that enforce precedence (WILL I ? What does this mean)
		
		for (local.layout in local.layouts) {
			local.layoutObj = this.layoutsObj.getLayout(local.layout);
			css &= "/* Layout #local.layout# */\n";
			// build complete list of cs
			StructAppend(local.content,local.layoutObj.content,false);
			// add to list of all containers used in site
			StructAppend(local.containerList,local.layoutObj.containers);
			// add to struct of all style schemes
			StructAppend(local.styles,local.layoutObj.style);

			css &= this.settingsObj.layoutCss(
				containers=local.layoutObj.containers, 
				styles=local.layoutObj.style,
				media=arguments.styleSettings.media,
				selector="body.template-#local.layout#"
			);
		}
				
		for (var id in local.containerList) {
			css &= "###id# {grid-area:#id#;}\n";
		}

		// Main content section styling
		css &= this.settingsObj.CSSCommentHeader("Content styling");
		
		css &= this.contentObj.contentCSS(content_sections=local.content,styles=local.styles,media=arguments.styleSettings.media, format=false);
		
		css = this.settingsObj.outputFormat(css=css,media=arguments.styleSettings.media,debug=variables.debug);
		
		return css;

	}
}