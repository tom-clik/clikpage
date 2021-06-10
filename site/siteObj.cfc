component {

	public siteObj function init(debug=false) {

		this.cr = chr(13) & chr(10);
		this.utils = CreateObject("component", "clikpage.utils.utilsold");	
		this.debug = arguments.debug;
		local.patternObj = createObject( "java", "java.util.regex.Pattern");
		variables.pattern = patternObj.compile("\{\{\w+?\.([\w\.]+)?\}\}" ,local.patternObj.MULTILINE + local.patternObj.CASE_INSENSITIVE);


		return this;
	}

	public struct function loadSite(required string filename) {

		if (!FileExists(arguments.filename)) {
			throw("Stylesheet #arguments.filename# not found");
		}

		local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
		local.site = this.utils.xml2data(local.xmlData);

		parseSections(local.site);

		return local.site;

	}

	private void function parseSections(required struct site) {
		
		local.sectionStr = {};

		local.sectionArray = [];

		for (local.section in arguments.site.sections) {
			local.sectionStr[local.section.code] = local.section; 
			ArrayAppend(local.sectionArray,local.section.code);
		}

		arguments.site["sections"] = local.sectionStr;
		arguments.site["sectionlist"] = local.sectionArray ;

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
	 * Get array of data for using as articles
	 * 
	 * @site         Site struct
	 * @sections     tag
	 */
	public array function getData(required struct site, required string tag) {

		local.data = [];

		for (local.article in arguments.site.data) {
			if (ListFindNoCase(local.article.tags, arguments.tag)) {
				local.articledata = {"content"="#local.article.strapline#","title"=local.article.title};
				if (local.article.image neq "") {
					local.articledata["image"] = local.article.image;
				}
				if (local.article.caption neq "") {
					local.articledata["caption"] = local.article.caption;
				}
				ArrayAppend(local.data,Duplicate(local.articledata));
			}
		}

		return local.data;

	}


	public string function dataReplace(required struct site, required string html, required string sectioncode, string action="index", string id="", struct pagecontent={}) {

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
			else if (local.scope == "page") {
				if (StructKeyExists(arguments.pagecontent, local.field)) {
					local.val  =  arguments.pagecontent[local.field];
				}
			}

			arguments.html = Replace(arguments.html, local.tag, local.val,"all");

		}

		return arguments.html;

	}

}