component accessors="true" extends="utils.baseutils" {

	property name="cr" type="string" default=newLine();
	property name="debug" type="boolean" default=true;
	property name="previewurl" type="string" default="index.cfm";
	
	public site function init(
		required string layoutsFolder,
		required dataObj
		) {
		
		this.settingsObj = new clikpage.settings.settings(debug=getdebug());
		this.contentObj = new clikpage.content.content(settingsObj=this.settingsObj,debug=getdebug());
		this.layoutsObj = new clikpage.layouts.layouts(arguments.layoutsFolder);

		this.pageObj = new clikpage.page(debug=getdebug());
		this.dataObj = arguments.dataObj;
		
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
		
		if (StructKeyExists(local.site, "style") ) {
			if (! isArray(local.site.style)) {
				local.site.style = [local.site.style];
			}
			local.site["styles"] = {};
			for (local.style in local.site.style) {
				try{
					this.settingsObj.loadStyleSheet( getCanonicalPath(local.root & local.style.href) , local.site.styles);
				} 
				catch (any e) {
					local.extendedinfo = {"tagcontext"=e.tagcontext};
					throw(
						extendedinfo = SerializeJSON(local.extendedinfo),
						message      = "Error:" & e.message, 
						detail       = e.detail,
						errorcode    = ""		
					);
				}
			}
			
			StructDelete(local.site,"style");

		}
		else {
			throw("No styles defined");
		}
		
		// load sections
		parseData(site=local.site,data=local.site.sections,type="sections",root=local.root);
		checkParentSections(site=local.site);

		addSectionData( site=local.site );

		// load other data from files
		// DEPRECATED, see dataObj
		// loadData( site=local.site,directory=local.root );
		
		// Load all separate (ie reusable) content sections
		loadContent( site=local.site, directory=local.root );

		// process styling from layouts
		loadSiteLayouts(local.site);

		// list of all containers used in site
		local.site["containers"] = [=];
		
		for (local.layout in local.site.layouts) {

			local.layoutObj = this.layoutsObj.getLayout(local.layout);
			// build complete struct of cs
			variables.utils.utils.deepStructAppend(local.site.content,local.layoutObj.content,false);
			// add to list of all containers used in site
			variables.utils.utils.deepStructAppend(local.site.containers,local.layoutObj.containers);
		}

		return local.site;

	}

	

	/**
	 * Use parent tag in sub sections to generate list of children
	 * in the parent section (array section.children)
	 */
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
		/*** Why in a loop? doesn't make any sense. TODO: fix this. Guess it's working for single entries */
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
	 * Slightly unusual here. Same function used for sections, articles, photos etc
	 * Possibly revisit
	 * 
	 * @site Site struct
	 * @data Array of data records
	 * @type Data type (key from site.data)
	 */
	private void function parseData(required struct site, required array data, required string type, string root="", string image_path="") {
		
		arguments.site[arguments.type] = [=];

		for (local.data in arguments.data) {

			switch(arguments.type) {
				case "sections":
					StructAppend(local.data,{"layout":arguments.site.layout},false);
					if (! StructKeyExists(local.data,"tags") ) {
						local.data.tags = {};
					}
					else if ( isSimpleValue( local.data.tags ) ) {
						local.data.tags = variables.utils.utils.listToStruct(local.data.tags);
					}
					break;
			}
			try {
				// checkFields(data=local.data,type=arguments.type,image_path=arguments.image_path,root=arguments.root);
			}
			catch (any e) {
				local.extendedinfo = {"tagcontext"=e.tagcontext,"data"=local.data,"type"=arguments.type};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Unable to parse record:" & e.message, 
					detail       = e.detail,
					type         = "custom"
				);
			}

			arguments.site[arguments.type][local.data.id] = local.data; 
			
		}

	}

	// TODO: formal definition of records with checking, defaults etc
	// private void function checkFields(required struct data, string type, string image_path="", string root="") {
		
	// 	local.metaData = {};

	// 	if ( StructKeyExists (arguments.data, "src") ) {
	// 		local.filename = GetCanonicalPath( arguments.root & arguments.data.src );
	// 		local.file = FileRead( local.filename ) ;
	// 		arguments.data["detail"] = variables.utils.flexmark.toHtml(local.file, local.metaData);
	// 		StructAppend( arguments.data,local.metaData );
	// 	}

	// 	if (!StructKeyExists(arguments.data,"id")) {
	// 		throw(message="No id defined for data record");
	// 	}

	// 	if (!StructKeyExists(arguments.data,"title")) {
	// 		throw(message="No title defined for record");	
	// 	}

	// 	if (!StructKeyExists(arguments.data,"short_title")) {
	// 		arguments.data["short_title"] = arguments.data.title;	
	// 	}	

	// 	for (local.field in ['detail','description']) {
	// 		if ( StructKeyExists(arguments.data, local.field) AND 
	// 			NOT StructKeyExists(local.metaData, local.field) 
	// 			) {
	// 			arguments.data[local.field] = Trim( variables.utils.flexmark.toHtml(arguments.data[local.field]) );
	// 		}
	// 	}

	// 	if (arguments.image_path NEQ "" ) {
	// 		for (local.field in ['image','image_thumb']) {
	// 			if (structKeyExists(arguments.data, local.field) AND arguments.data[local.field]  NEQ "" ) {
	// 				arguments.data[local.field] = arguments.image_path & arguments.data[local.field];					
	// 			}
	// 		}
	// 	}

	// 	StructAppend(arguments.data,{"tags":"","detail":"","description":"","live":true,"pubdate":nullValue(),"sort_order":0,"image":""},false);

	// 	if (!isBoolean(arguments.data.live)) {
	// 		throw(message="Live value is not boolean");		
	// 	}
	// 	if (!isNull(arguments.data.pubdate) AND !isDate(arguments.data.pubdate)) {
	// 		throw(message="Invalid value for pubdate");			
	// 	}

	// 	switch(arguments.type) {
	// 		case "sections":
	// 			if (!StructKeyExists(arguments.data,"layout")) {
	// 				throw("No layout defined for section #arguments.data.id#");
	// 			}
	// 			break;
	// 	}

	// 	// convert tags list to set
	// 	local.tagsStr = [=];
	// 	for (local.tag in ListToArray(arguments.data.tags)) {
	// 		local.tagsStr[local.tag] = 1;
	// 	}
	// 	arguments.data.tags = local.tagsStr;
		
	// }


	/**
	 * Add sections defined in the data to section records
	 */
	private void function addSectionData( required struct site ) localmode=true {

		var sectionList = StructKeyArray( arguments.site.sections );
		sectionData = this.dataObj.getRecords( sectionList );

		for (section in sectionList) {
			if ( sectionData.keyExists(section) ) {
				variables.utils.utils.deepStructAppend( arguments.site.sections[section], sectionData[section], false );
			}
		}

	}

	/**
	 * Get list of sections by tag
	 */
	public array function sectionList(required struct site, required string tag) {

		sections = [];
		
		for (section in arguments.site.sections) {
			if ( arguments.site.sections[section].tags.keyExists(tag) ) {
				sections.append(section)
			}
		}

		return sections;

	}

	/**
	 * @hint Get array of data for using in menu components
	 *
	 * TODO: will eventually need to recreate sub menu functionality for articles and galleries
	 * 
	 * @site         Site struct
	 * @sections     Array or list of section codes
	 */
	public array function menuData(required struct site, required any sections) {

		if (! isArray(arguments.sections) ) {
			arguments.section = listToArray(arguments.sections);
		}
		local.menuDataArr = [];

		// datares = structKeyArray(variables.data).filter(function(item) { return hasTag(item, tags) ; });

		for (local.sectioncode in arguments.sections) {
			
			local.section = arguments.site.sections[local.sectioncode];
			
			local.item = {"link"="{{link.#local.sectioncode#}}","id"="#local.sectioncode#","title"=local.section.title};
			
			if (local.section.keyExists("children")) {
				local.item["submenu"] = menuData(site=arguments.site, sections=local.section.children );
			}

			ArrayAppend(local.menuDataArr, local.item);
		
		}

		return local.menuDataArr;

	}

	public string function getDataSetType(
		required struct dataset
		) {
		return dataset.type ? : "articles";
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
		
		arguments.record["next_link"] = info.next neq "" ? pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = arguments.dataset[info.next]) : "";

		arguments.record["previous_link"] = info.previous neq "" ? pageLink(site=arguments.site, section=arguments.section, action=arguments.action, id = arguments.dataset[info.previous]) : "";
		
		if (info.next neq "") {
			arguments.record["next_title"] = this.dataObj.getRecord(site=arguments.site, ID=arguments.dataset[info.next], type=arguments.type)["title"];
		}

		if (info.previous neq "") {
			arguments.record["previous_title"] = this.dataObj.getRecord(site=arguments.site, ID=arguments.dataset[info.previous], type=arguments.type)["title"];
		}

	}

	/**
	 * add links to a sub section for next,previous,parent
	 */
	public void function addSectionLinks(
		required struct section, 
		required array  dataset, 
		required struct site, 
		) {

		var info = getRecordSetInfo(site=arguments.site,dataset=arguments.dataset,id=arguments.section.id);
		
		StructAppend(arguments.section,
			{
				"next_link" = "",
				"next_title" = "",
				"previous_link" = "",
				"previous_title" = "",
				"parent_title" = "",
				"parent_link" = ""
			}
		);

		if (info.next neq "") {
			local.next = arguments.dataset[info.next];
			arguments.section["next_link"] = pageLink(site=arguments.site, section=local.next);
			arguments.section["next_title"] = arguments.site.sections[local.next]["title"];
		}

		if (info.previous neq "") {
			local.previous = arguments.dataset[info.previous];
			arguments.section["previous_link"] = pageLink(site=arguments.site, section=local.previous)
			arguments.section["previous_title"] = arguments.site.sections[local.previous]["title"];
		}

		arguments.section["parent_title"] = arguments.site.sections[arguments.section.parent]["title"];
		arguments.section["parent_link"] = pageLink(site=arguments.site, section=arguments.section.parent);
		
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
			if (arguments.action neq "index" and arguments.id eq "") {
				local.link &= "_#arguments.action#";
			}
			if (arguments.id neq "") {
				local.link &= "_#arguments.id#";
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
	 * @hint Add javascript files for data definitions to a page struct
	 *
	 * TODO: break down by gallery/category or similar. Only load the ones we
	 * need
	 * TODO: Configure location of saved files (also styles)
	 */
	private void function addJSData(required struct pageContent) {

		this.pageObj.addJs(arguments.pageContent,"scripts/sitedata.js");

	}

	/**
	 * @hint Display a page.
	 *
	 * WIP at the minute. Much needs to be sorted here.
	 * 
	 */
	public struct function page(required struct pageRequest, required struct site) {

		var pageContent = this.pageObj.getContent();
		addJSData(pageContent);

		local.rc = {};
		local.rc.sectionObj = getSection(site=arguments.site,section=arguments.pageRequest.section);

		// WTF. TODO: sort this
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
		
			The cs can also define their data sets themselves. For a menu,
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

			local.rc.record = Duplicate( this.dataObj.getRecord(site=arguments.site,id=arguments.pageRequest.id, type=local.type ));

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

				if ( StructKeyExists( arguments.site.content[contentid] , "dataset") &&
					! arguments.site.content[contentid].dataset.keyExists("name")
					 )  {
					arguments.site.content[contentid].dataset["name"] = "content_" & contentid;
				}
				// hardwired for list types at the minute. what to do???
				// reasonably easy to define data sets but what about the links
				// TO DO: linkto functionality for the lists
				// article/image lists might link to another section
				// sub section links need to link to the section
				switch (arguments.site.content[contentid].type) {
					case "articlelist":
					case "imagegrid":
						
						if ( StructKeyExists( arguments.site.content[contentid] , "dataset") )  {
							arguments.site.content[contentid].data = this.dataObj.getDataSet(
								site=arguments.site,
								dataset=arguments.site.content[contentid].dataset,
								fields={"parent":arguments.pageRequest.section}
							);
						}
						else if ( StructKeyExists( local.rc.sectionObj,"data" ) ) {
							arguments.site.content[contentid].data = local.rc.sectionObj["data"];

						}
						else {
							throw("No data set defined");
						}
						local.data =  this.dataObj.getRecords(arguments.site.content[contentid].data);
						break;
					case "menu":

						// TODO: resurrect "content" sub menus
						// if ( StructKeyExists( arguments.site.content[contentid] , "dataset") )  {
						// 	local.fields = {};
						// 	if ( local.rc.sectionObj.keyExists( "parent" )) {
						// 		local.fields["parent"] = local.rc.sectionObj.parent;
						// 	}
						// 	local.menuDataSet = this.dataObj.getDataSet(
						// 		site=arguments.site,
						// 		dataset=arguments.site.content[contentid].dataset,
						// 		fields=local.fields
						// 	);
						// 	local.datatype = arguments.site.content[contentid].dataset.type;
						// }
						// else {
						// 	local.menuDataSet = arguments.site.content[contentid].data = this.dataObj.getDataSet(
						// 		site=arguments.site,
						// 		dataset={"tag"=contentid,type="sections"},
						// 		fields={"parent":arguments.pageRequest.section}
						// 	);
						// 	local.datatype = "sections";
						// }
						
						local.sections = sectionList( site=arguments.site,"tag"=contentid )
						arguments.site.content[contentid].data = menuData(site=arguments.site,sections=local.sections);

						local.data = arguments.site.sections;

						break;
					case "form":

						local.xmlData = XmlParse( this.contentObj.contentSections.form.sampleForm() );
						local.formdata = variables.utils.XML.xml2data(local.xmlData);

						arguments.site.content[contentid].data = this.contentObj.contentSections.form.parseForm(local.formdata);
						local.data = {};
					
				}

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

		
		// TODO: setting somewhere to include this or not
		// pageContent.onready &= "$(""##ubercontainer"").mCustomScrollbar();";
		// pageContent.css &= "body {height:100vh;overflow:hidden};";
		// pageContent.static_js["scrollbar"] = 1;
		// pageContent.static_css["scrollbar"] = 1;
		
		pageContent.body = "<div id='bodyWrapper' class='container'>" & this.layoutsObj.getHTML(local.rc.layout) & "</div>";
		
		pageContent.body = dataReplace(site=arguments.site, html=pageContent.body, sectioncode=arguments.pageRequest.section, record=local.rc.record);
		
		pageContent.body &= local.errorsHtml;

		// WILLDO: remove this. Leave for now as it's useful sometimes
		// savecontent variable="local.temp" {
		// 	writeDump(local.rc.record);
		// 	writeDump(local.rc.sectionObj.data);
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
				if (! arguments.section.dataset.keyExists("name") ) {
					arguments.section.dataset["name"] = "section_" & arguments.section.id;
				}
				arguments.section.data = this.dataObj.getDataSet(
					site=arguments.site,
					dataset=arguments.section.dataset
				);
			} 
			else if ( StructKeyExists(arguments.section, "children") ) {
				arguments.section.dataset = {"type":"sections"};
				arguments.section.data = arguments.section.children;
			}
			else {
				arguments.section.data = [];
			}
			// NOT ideal...we add the sub section links here as well
			// Possibly need a separate check
			if ( StructKeyExists(arguments.section, "parent") ) {
				local.parent = arguments.site.sections[arguments.section.parent];
				loadSectionData(site=arguments.site,section=local.parent);
				addSectionLinks(
					section=arguments.section,
					dataset=local.parent.data,
					site=arguments.site
				);
			}
		}
		// manually supplied IDs.
		else if (! isArray( arguments.section.data ) ) {
			arguments.section.data = listToArray(arguments.section.data);
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
	 * @hint Get a list of all layouts used in the site
	 *
	 * XML might be defined like this. 
	 * 
	 * <layout>articlelist</layout>
	 * <layout action="view">articledetail</layout>
	 *
	 * It will create a array
	 *
	 * ['articlelist',{"action":"view","value":"articledetail"}]
	 * 
	 */
	private void function loadSiteLayouts(required struct site) {
		
		local.layouts = [=];
		
		// site has a default layout
		if ( StructKeyExists(arguments.site, "layout") ) {
			local.layouts[arguments.site.layout] = 1;
		}
		// See notes on getLayoutName for structure of layouts
		// 	
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
							// e.g from <layout action="view">articledetail</layout>
							local.layouts[local.layoutAction.value] = 1;
						}
					}
				}
				
			}
		}

		arguments.site["layouts"] = StructKeyArray(local.layouts);

	}
	
	string function siteCSS(required struct site, boolean debug=variables.debug) {
	
		var css = "";
		var cr = arguments.debug ? newLine() : "";
		
		css &= ":root {#cr#";
		css &= this.settingsObj.colorVariablesCSS(arguments.site.styles,arguments.debug);
		css &= this.settingsObj.fontVariablesCSS(arguments.site.styles,arguments.debug);
		css &= this.settingsObj.variablesCSS(arguments.site.styles,arguments.debug);
		css &=  "#cr#}#cr#";
		css &= this.settingsObj.CSSCommentHeader("Layouts");
		
		local.written = {};
		for (local.layout in arguments.site.layouts) {

			try{
				css &= getLayoutCss(layoutName=local.layout,site=arguments.site, written=local.written,debug=arguments.debug );
			}
			catch (any e) {
				local.extendedinfo = {"error"=e};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Unable to write styling for template #local.layout#:" & e.message, 
					detail       = e.detail
				);
			}
		}

		for (var id in arguments.site.containers) {
			css &= "###id# {grid-area:#id#;}#cr#";
		}

		// Main content section styling
		css &= this.settingsObj.CSSCommentHeader("Content styling");
		
		css &= this.contentObj.contentCSS(content_sections=arguments.site.content,styles=arguments.site.styles,debug=arguments.debug);
		
		return css;

	}

	/** Get CSS for individual layout 
	 * 
	 * @layoutName    Name of layout
	 * @site          Site struct
	 * @written       Struct to ensure "extends" layouts only get written once
	 */
	private string function getLayoutCss(required string layoutName, required struct site, struct written={}, boolean debug=variables.debug ) {
		
		local.css = "";
		local.layoutObj = this.layoutsObj.getLayout(arguments.layoutName);
		
		if (StructKeyExists(local.layoutObj, "extends" ) &&
			NOT StructKeyExists( arguments.written, local.layoutObj.extends) ) {
			local.css &= getLayoutCss(layoutName=local.layoutObj.extends, site=arguments.site, written=arguments.written, debug=arguments.debug );
			arguments.written[local.layoutObj.extends] = 1;
		}

		local.styles = local.layoutObj.style ? : {};
		variables.utils.utils.deepStructAppend(local.styles, arguments.site.styles,false);

		if ( arguments.debug ) {
			local.css &= "/* Layout #arguments.layoutName# */" & newLine();
		}

		// Add individual cs styling to the stylesheet
		for ( local.code in local.layoutObj.content ) {
			local.csObj = local.layoutObj.content[local.code];
			if ( local.csObj.keyExists( "style" ) ) {
				StructAppend( arguments.site.styles, { "#local.code#": local.csObj.style }, true);
			}
		}

		local.css &= this.settingsObj.layoutCss(
			containers=local.layoutObj.containers, 
			styles=local.styles,
			media=arguments.site.styles.media,
			selector="body.template-#arguments.layoutName#",
			debug=arguments.debug
		);

		arguments.written[arguments.layoutName] = 1;
		
		return local.css;
	}

	// Save a static version of a site
	public struct function save(
		required struct site, 
		required string outputDir,
				 boolean debug=0) {

		arguments.site.mode = "static";
		
		var ret = {
			"pages": [=]
		};

		checkoutputDirectories(arguments.outputDir)
		
		local.outfile = arguments.outputDir & "/styles/styles.css";
		local.css = siteCSS(site=arguments.site,debug=arguments.debug);
		FileWrite(local.outfile, local.css);

		saveData(site=arguments.site,outputDir=arguments.outputDir & "/scripts");

		for (local.section in arguments.site.sections) {
			local.sectionObj = getSection(site=arguments.site,section=local.section);
			loadSectionData(site=arguments.site, section=local.sectionObj);

			local.pageRequest = {"section":local.section,"action":"index","id":""};
			local.page = saveStaticPage(site=arguments.site, pageRequest=local.pageRequest,outputDir=arguments.outputDir,debug=arguments.debug);
			ret.pages[local.page] = 1;

			// TODO: better definitions of whether we have sub pages or not
			// Need to think about galleries and sections with single items.
			// 
			if ( StructKeyExists( local.sectionObj, "dataset") AND  local.sectionObj.dataset.type NEQ "sections"
				AND arrayLen(local.sectionObj.data) GT 1) {
				for (local.id in local.sectionObj.data) {
					local.pageRequest = {"section":local.section,"action":"view","id":local.id};
					local.page = saveStaticPage(site=arguments.site, pageRequest=local.pageRequest,outputDir=arguments.outputDir,debug=arguments.debug);
					ret.pages[local.page] = 1;
				}
			}

		}

		return ret;

	}
	
	/**
	 * Check all sub folders for a site exists: See save()
	 */
	private void function checkoutputDirectories(required string outputDir) {
		
		if (! DirectoryExists(arguments.outputDir)) {
			throw("Directory #arguments.outputDir# not found");
		}
		local.subFolders = ["scripts","styles"];

		for (local.folder in local.subFolders) {
			local.scriptFolder = arguments.outputDir & "/" & local.folder;
			if (! DirectoryExists( local.scriptFolder ) ) {
				try{
					DirectoryCreate(local.scriptFolder);
				} 
				catch (any e) {
					throw(
						message      = "Unable to create output directory #local.scriptFolder#:" & e.message, 
						detail       = e.detail,
						errorcode    = "site.save.001"		
					);
				}
			}
		}
	}


	// See save()
	private string function saveStaticPage(
		required struct site,
		required struct pageRequest,
		required string outputDir,
		         boolean debug=0
		) {
		
		local.filename = pageLink(
			site    = arguments.site, 
			section = arguments.pageRequest.section, 
			action  = arguments.pageRequest.action, 
			id      = arguments.pageRequest.id
		);
		
		local.content = page(arguments.pageRequest, arguments.site);

		if (arguments.debug) {
			local.content.onready = this.pageObj.jsStaticFiles.removeJsComments(local.content.onready);
		}

		local.content.static_js["main"] = 1;
		local.content.static_css["content"] = 1;

		this.pageObj.addCss(local.content,"styles/styles.css");

		if (StructKeyExists(arguments.site,"links")) {
			for (local.link in arguments.site.links) {
				this.pageObj.addLink(content=local.content,argumentcollection=local.link);	
			}
		}

		local.html = this.pageObj.buildPage(content=local.content,debug=arguments.debug);
		FileWrite(arguments.outputDir & "/" & local.filename, local.html);

		return local.filename;

	}

	/**
	 * @hint Save site data to JavaScript data objects
	 * 
	 * Save the complete records of data. 
	 *
	 * TODO: completely broken. Needs rethinking anyway to split into chunks of some sort.
	 */
	public void function saveData(
		required struct site,
		required string outputDir
		) {
		local.js = "if ( typeof site == 'undefined' ) site = {};";
		local.js &= "site.data = {};"
		local.js &= "site.data.images = " & serializeJSON( this.dataObj.getRecords([]) ) & ";";
		local.js &= "site.data.articles = " & serializeJSON( this.dataObj.getRecords([]) ) & ";";
		try{
			FileWrite(arguments.outputDir & "/" & "sitedata.js", local.js);
		} 
		catch (any e) {
			local.extendedinfo = {"error"=e,"file"="sitedata.js","directory"=arguments.outputDir};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Unable to save JS file:" & e.message
			);
		}
		
	}

}