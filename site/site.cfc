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

		variables.pattern = variables.utils.patternObj.compile("\{\{[\w\.]+?\}\}" ,variables.utils.patternObj.MULTILINE + variables.utils.patternObj.CASE_INSENSITIVE);

		return this;
	}

	/* clear any caching */
	public void function cacheClear() {
		this.layoutsObj.cacheClear();
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

		local.root = GetDirectoryFromPath(arguments.filename);

		local.xmlData = variables.utils.utils.fnReadXML(arguments.filename,"utf-8");
		local.site = variables.utils.XML.xml2data(local.xmlData);
		
		local.site["mode"] = "preview";

		if (NOT StructKeyExists(local.site,"layout")) {
			throw("No layout defined for site");
		}
		if (NOT StructKeyExists(local.site,"stylesettings")) {
			throw("No stylesettings defined for site");
		}

		if (StructKeyExists(local.site.stylesettings,"src")) {
			local.site.stylesettings = this.settingsObj.loadStyleSettings( getCanonicalPath( local.root & local.site.stylesettings.src ) );
		}
		else {
			throw("Only src supported for stylesettings at this time");
		}

		// load sections
		parseData(site=local.site,data=local.site.sections,type="sections");
		checkParentSections(site=local.site);

		// load other data from files
		loadData( site=local.site,directory=local.root );
		
		// process styling from layouts
		loadSiteLayouts(local.site);

		// complete struct of all cs
		loadContent( site=local.site, directory=local.root );

		// list of all containers used in site
		local.site["containers"] = [=];
		// complete struct of all styles - may have globale settings like schemes
		// or library components in there already (defined in stylesettings)
		if ( StructKeyExists(local.site.stylesettings,"style") ) {
			local.site["style"] = Duplicate(local.site.stylesettings.style);
		}
		else {
			local.site["style"] = {};
		}

		for (local.layout in local.site.layouts) {

			local.layoutObj = this.layoutsObj.getLayout(local.layout);
			// build complete list of cs
			variables.utils.utils.deepStructAppend(local.site.content,local.layoutObj.content,false);
			// add to list of all containers used in site
			variables.utils.utils.deepStructAppend(local.site.containers,local.layoutObj.containers);
		}

		// Load the settings for every content section. Combination
		// of styles and defaults. Applies inheritance according to media
		this.contentObj.loadSettings(
			styles = local.site.style, 
			content_sections = local.site.content, 
			media = local.site.stylesettings.media
		);		

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
		
		// cope with one record not being array
		if (NOT IsArray(arguments.site.data)) {
			arguments.site.data = [arguments.site.data.data]
		}

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
					// chekc single record
					if (StructCount(local.records) eq 1) {
						local.records = [local.records[structKeyList(local.records)]];
					}
					else {
						throw("Data is not array. If you only have one record");
					}
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

	// Add children (array) to parent sections
	// And also {parent} tag to sub sections
	private void function checkParentSections( required struct site ) {

		for ( local.section_code in arguments.site.sections ) {
			local.section = arguments.site.sections[local.section_code];
			if ( StructKeyExists( local.section, "parent" ) ) {
				local.parent = arguments.site.sections[local.section.parent];
				if ( ! StructKeyExists( local.parent, "children" ) ) {
					local.parent["children"] = [];
				}
				ArrayAppend( local.parent.children, local.section_code );
				local.section.tags["#local.section.parent#"] = 1;
			}
		}

	}


	/** 
	 * @hint Load content items from files
	 *
	 * Content items can be defined in their own files. Import them and add
	 * them to the general struct.
	 *
	 * We first concatentate them if they are in separate files and then
	 * call the parseContentSections method of the layouts component. 
	 *
	 */
	private void function loadContent(
		required struct site, 
		required string directory
		) {
		
		if (! StructKeyExists(arguments.site, "content")) {
			arguments.site.content = {};
			return;
		}

		if (! isArray(arguments.site.content) ) {
			arguments.site.content = [arguments.site.content];
		}

		for (local.link in arguments.site.content) {
			local.match = ListLast(local.link.import, "\/");
			local.dir = arguments.directory & "/" & Replace(local.link.import, local.match, "");
			local.glob = DirectoryList(local.dir,true,"path",local.match);
		}

		local.csData = "";
		for ( local.csFile in local.glob ) {
			local.csData &= FileRead(local.csFile);
		}

		local.html = this.layoutsObj.replaceFieldNames(local.csData);
		local.layout = {"id"="importCSS"};
		local.layout["layout"] = this.layoutsObj.coldsoup.parse(local.html);
		this.layoutsObj.parseContentSections(local.layout);
		
		arguments.site.content = local.layout.content;
		
	}

	/** 
	 * @hint Convert XML parsed array into struct keyed by code 
	 *
	 * Slightly unusual here. Swme function used for sections, articles, photos etc
	 * Possibly revisit
	 * 
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

		// convert tags list to set
		local.tagsStr = [=];
		for (local.tag in ListToArray(arguments.data.tags)) {
			local.tagsStr[local.tag] = 1;
		}
		arguments.data.tags = local.tagsStr;
		
	}

	/**
	 * @hint Get array of data for using in menu components
	 *
	 * Use normal dataset functionality to get array of section 
	 * codes. Then call this to get menu data.
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
	 * @dataset      see notes. 
	 * @data         Replace {field} in the dataset with these values
	 */
	public array function getDataSet(
		required struct site, 
		required struct dataset,
				 struct fields = {}
		) {

		StructAppend(arguments.dataset,{"tag":"","type":"articles"},false);

		local.data = [];

		// return all data for a type if no filter
		if (arguments.dataset.tag eq "") {
			return structKeyArray(arguments.site[arguments.dataset.type]);
		}

		// alias the data we are looking at
		local.ref = arguments.site[arguments.dataset.type];
		local.tag =  arguments.dataset.tag;

		for (local.field in arguments.fields) {
			local.tag = Replace(local.tag, "{" & local.field & "}", arguments.fields[local.field])
		}

		for (local.id in local.ref) {
			
			local.record = local.ref[local.id];

			if (  local.record.tags.keyExists( local.tag ) ) {
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

		try {
			return arguments.site[arguments.type][arguments.id];
		}
		catch (any e) {
			local.extendedinfo = {tagcontext=e.tagcontext,data=arguments.site[arguments.type],type=arguments.type,id=arguments.id};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error getting data record:" & e.message, 
				detail       = e.detail,
				errorcode    = "site.getRecord"		
			);
		}

		
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
			arguments.record["next_title"] = getRecord(site=arguments.site, ID=arguments.dataset[info.next], type=arguments.type)["title"];
		}

		if (info.previous neq "") {
			arguments.record["previous_title"] = getRecord(site=arguments.site, ID=arguments.dataset[info.previous], type=arguments.type)["title"];
		}


	}
	

	/**
	 * @hint Replace all data placeholders in the HTML with data values
	 */
	public string function dataReplace(
		required struct site, 
		required string html, 
		required string sectioncode, 
		         string action="index", 
		         string id="", 
		         struct record={}
		) {

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

			Note that a child section will by default inherit the parent
			data set.
			
			They can also define their data sets themselves. For a menu,
			this default is a search by a tag.

			We want to cache the results.

		 */
		
		loadSectionData(site=arguments.site, section=local.rc.sectionObj);

		if (ArrayLen (local.rc.sectionObj.data) ) {
			
			local.type = getDataType(local.rc.sectionObj);

			// always gets record -- maybe do something about this
			if (arguments.pageRequest.id eq "") {
				arguments.pageRequest.id = local.rc.sectionObj["data"][1];
			}

			local.rc.record = Duplicate(getRecord(site=arguments.site,id=arguments.pageRequest.id, type=local.type ));

			addPageLinks(record=local.rc.record, dataset=local.rc.sectionObj.data, site=arguments.site,section=arguments.pageRequest.section,action="view",type=local.type);
		}
		else if ( arguments.pageRequest.id != "" ) {
			throw(message="section data not defined",detail="You must define a dataset for a section to use the record functionality");
		}
		
		local.errorsHtml = "";
		// todo: add as method of content object
		for (var contentid in local.rc.layout.content) {
			
			var csdata = local.rc.layout.content[contentid];
			// TODO: remove true
			if (TRUE OR ! StructKeyExists(arguments.site.content, contentid)) {
				
				local.data = {};
				local.datatype = "sections";
				// hardwired for list types at the minute. what to do???
				// reasonably easy to define data sets but what about the links
				// TO DO: linkto functionality for the lists
				// article/image lists might link to another section
				// sub section links need to link to the section
				switch (arguments.site.content[contentid].type) {
					case "articlelist":
					case "imagegrid":
						
						if ( StructKeyExists( arguments.site.content[contentid] , "dataset") )  {
							arguments.site.content[contentid].data = getDataSet(
								site=arguments.site,
								dataset=arguments.site.content[contentid].dataset,
								fields={"parent":arguments.pageRequest.section}
							);
							local.datatype = arguments.site.content[contentid].dataset.type;

						}
						else if ( StructKeyExists( local.rc.sectionObj,"data" ) ) {
							local.datatype = local.type = getDataType(local.rc.sectionObj);
							arguments.site.content[contentid].data = local.rc.sectionObj["data"];
						}
						else {
							throw("No data set defined");
						}

						break;
					case "menu":
						if ( StructKeyExists( arguments.site.content[contentid] , "dataset") )  {
							local.fields = {};
							if ( local.rc.sectionObj.keyExists( "parent" )) {
								local.fields["parent"] = local.rc.sectionObj.parent;
							}
							
							local.menuDataSet = getDataSet(
								site=arguments.site,
								dataset=arguments.site.content[contentid].dataset,
								fields=local.fields
							);
							local.datatype = arguments.site.content[contentid].dataset.type;
							
						}
						else {
							local.menuDataSet = arguments.site.content[contentid].data = getDataSet(
								site=arguments.site,
								dataset={"tag"=contentid,type="sections"},
								fields={"parent":arguments.pageRequest.section}
							);
							local.datatype = "sections";
						}
						arguments.site.content[contentid].data = menuData(arguments.site,local.menuDataSet);
						
						break;
					
				}

				local.data = arguments.site[local.datatype];

			}
			
			local.tag=local.rc.layout.layout.select("###contentid#").first();
			
			// TO do: use display method
			// and cache results
			try {
				local.html = this.contentObj.html(content=arguments.site.content[contentid],data=local.data);
			}
			catch (Any e) {
				local.html = "issue with #contentid#";
				savecontent variable="local.debug" {
					writeDump(e);
				}
				local.errorsHtml &= local.debug;
			}

			local.tag.html(local.html);
			
			local.tag.attr("class",this.contentObj.getClassList(arguments.site.content[contentid]));
			
			this.contentObj.addPageContent(pageContent,this.contentObj.getPageContent(arguments.site.content[contentid],local.data));
			
			
		}
		pageContent.css = this.settingsObj.outputFormat(css=pageContent.css,media=arguments.site.styleSettings.media);

		// TODO: setting somewhere to include this or not
		// pageContent.onready &= "$(""##ubercontainer"").mCustomScrollbar();";
		// pageContent.css &= "body {height:100vh;overflow:hidden};";
		// pageContent.static_js["scrollbar"] = 1;
		// pageContent.static_css["scrollbar"] = 1;
			

		pageContent.body = this.layoutsObj.getHTML(local.rc.layout);

		pageContent.body = dataReplace(site=arguments.site, html=pageContent.body, sectioncode=arguments.pageRequest.section, record=local.rc.record);
		
		pageContent.body &= local.errorsHtml;

		// WILLDO: remove this. Leave for now as it's useful sometimes
		// savecontent variable="local.temp" {
		// 	writeDump(local.rc.sectionObj);
		// 	// writeDump(arguments.site.content["sectionmenu"]);
		// }
		// pageContent.body &= local.temp;

		return pageContent;
	}

	/**
	 * @hint Load data for section into section.data
	 * 
	 */
	private void function loadSectionData(site, section) {
		if ( ! StructKeyExists( arguments.section, "data" ) ) {
			if ( StructKeyExists(arguments.section, "dataset") ) {
				arguments.section.data = getDataSet(
					site=arguments.site,
					dataset=arguments.section.dataset
				);
			}
			else if ( StructKeyExists(arguments.section, "children") ) {
				arguments.section.data = arguments.section.children;
			}
			else if ( StructKeyExists(arguments.section, "parent") ) {
				arguments.section.data = arguments.site.sections[arguments.section.parent].children;
			}
			else {
				arguments.section.data = [];
			}
		}
	}

	/**
	 * Get type of data in section data set
	 *
	 */
	private string function getDataType(section) {

		local.type = "sections";
				
		if ( StructKeyExists(arguments.section, "dataset") ) {
			local.type = arguments.section.dataset.type ? : "articles";
		}
		
		return local.type;
	}

	/**
	 * Get a list of all layouts used in the site
	 */
	private void function loadSiteLayouts(required struct site) {
		
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

		arguments.site["layouts"] = StructKeyArray(local.layouts);

	}
	
	string function siteCSS(required struct site) {
	
		var css = "";
		
		css &= ":root {\n";
		css &= this.settingsObj.colorVariablesCSS(arguments.site.styleSettings);
		css &= this.settingsObj.fontVariablesCSS(arguments.site.styleSettings);
		css &= this.settingsObj.variablesCSS(arguments.site.styleSettings);
		css &=  "\n}\n";
		css &= this.settingsObj.CSSCommentHeader("Layouts");
		
		local.written = {};
		for (local.layout in arguments.site.layouts) {
			try{
				css &= getLayoutCss(layoutName=local.layout,site=arguments.site, written=local.written );
			} 
			catch (any e) {
				throw(
					extendedinfo = e.extendedinfo,
					message      = "Unable to write styling for template #local.layout#:" & e.message, 
					detail       = e.detail
				);
			}
		}

		for (var id in arguments.site.containers) {
			css &= "###id# {grid-area:#id#;}\n";
		}

		// Main content section styling
		css &= this.settingsObj.CSSCommentHeader("Content styling");
		
		css &= this.contentObj.contentCSS(content_sections=arguments.site.content,styles=arguments.site.style,media=arguments.site.styleSettings.media, format=false);
		
		css = this.settingsObj.outputFormat(css=css,media=arguments.site.styleSettings.media,debug=variables.debug);
		
		return css;

	}
	/** Get CSS for individual layout 
	 * 
	 * @layoutName    Name of layout
	 * @site          Site struct
	 * @written       Struct to ensure "extends" layouts only get written once
	 */
	private string function getLayoutCss(required string layoutName, required struct site, struct written={} ) {
		
		local.css = "";
		local.layoutObj = this.layoutsObj.getLayout(arguments.layoutName);
		
		if (StructKeyExists(local.layoutObj, "extends" ) &&
			NOT StructKeyExists( arguments.written, local.layoutObj.extends) ) {
			local.css &= getLayoutCss(layoutName=local.layoutObj.extends, site=arguments.site, written=arguments.written );
			arguments.written[local.layoutObj.extends] = 1;
		}

		local.styles = local.layoutObj.style ? : {};
		variables.utils.utils.deepStructAppend(local.styles, arguments.site.style,false);

		local.css &= "/* Layout #arguments.layoutName# */\n";
		local.css &= this.settingsObj.layoutCss(
			containers=local.layoutObj.containers, 
			styles=local.styles,
			media=arguments.site.styleSettings.media,
			selector="body.template-#arguments.layoutName#"
		);

		arguments.written[arguments.layoutName] = 1;
		
		return local.css;
	}
}