component implements="clikpage.data.i_data" {

	function init(struct params={}) {

		if (! arguments.params.keyExists("dataFolder") ) {
			throw("dataFolder must be defined to use text data storage");
		}

		variables.directory = arguments.params.dataFolder;

		StructAppend(arguments.params, {"markdown"=true,"json"=true,"xml"=true, "reload"=1}, false);

		if ( arguments.params.markdown ) {
			variables.markdown = new markdown.flexmark(attributes=1);
		}

		// Monitor files for updates and reload when changed
		variables.reload = arguments.params.reload;

		variables.dataSets = {};
		variables.data = {};

		variables.datatypes = {
			"title": "string",
			"description": "string",
			"pubdate": "date",
			"sort_order": "numeric"
		}

		loadData(variables.directory);

	}

	// Check whether a styling file has been modified. Just playing with this
	// idea at the minute.
	private boolean function checkStylesChanged() localmode=true {
		
		if ( ! StructKeyExists(variables,"datelastmodified") ) {
			loadData();
			return true;
		}

		filelist = getFileList();
		
		changed = false;

		for (row in filelist) {
			if ( row.dateLastModified > variables.datelastmodified ) {
				loadFile(row.directory & "/" & row.filename);
				changed = true;
			}
		}

		if (changed) {
			variables.datelastmodified = now();
			StructClear(variables.dataSets);
		}
		
		return changed;

	}

	private query function getFileList() localmode=true {
		
		return DirectoryList(variables.directory,true,"query","*.md","name asc","file");
		
	}

	/** Load data files specified in site.data 
	 * 
	 *
	 */
	
	private void function loadData() localmode=true {
		
		filelist = getFileList();

		for (row in filelist) {
			loadFile(row.directory & "/" & row.name);
		}
		variables.datelastmodified = now();
		StructClear(variables.dataSets);

	}

	private void function loadFile(required string filename) localmode=true {
		
		record = {};
		html = variables.markdown.toHtml( fileRead(arguments.filename) , record);
		StructAppend(record, {"body"=html, "tags"={}, "pubdate"=now(), "sort_order"=0, "description"=""}, false);
		if ( isSimpleValue(record.tags) ) {
			tmpTags = {};
			for (tag in ListToArray(record.tags) ) {
				tmpTags[tag] = 1;
			}
			record.tags = tmpTags;
		}

		if (! isInstanceOf(record.pubdate, "java.util.Date")) {
			try {
				record.pubdate = ParseDateTime(record.pubdate);
			}
			catch (any e) {
				record.pubdate = nullValue();
			}
		}	

		// Use directory as a tag... will be a bit funny if not in a sub dir but no matter
		type  = ListLast(getDirectoryFromPath(arguments.filename),"/\");
		record.tags["#type#"] = 1;

		if (! record.keyExists("id") ) record["id"] = ListFirst(getFileFromPath(arguments.filename),".")

		variables.data["#record.id#"] = record;
	}

	private void function loadXML(required text) localmode=true {
		try {
			XMLData = XmlParse(arguments.text);
		}
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext, "text"=arguments.text};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error:" & e.message, 
				detail       = e.detail,
				errorcode    = ""		
			);
		}
	}


			<cfcatch>
				<cfthrow message="Unable to parse XML file" detail="fnReadXML():Unable to parse file #arguments.filepath#<br><br>#cfcatch.message#<br><br>#cfcatch.detail#">
			</cfcatch>
	     </cftry>

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
			parseData(site=arguments.site,data=local.records,type=local.data.type,image_path=local.image_path,root=arguments.directory);
		}
	}

	/**
	 * Get array of data IDs that match data set filter criteria
	 * 
	 * @dataset      Struct with keys name, tag (list of tags) and optionally sort_order (default = title asc).
	 *
	 * 
	 */
	public array function getDataSet (
		required struct dataset
		)   localmode=true {

		if (variables.reload) checkStylesChanged();

		if ( ! variables.dataSets.keyExists(arguments.dataset.name) ) {

			tags = ListToArray( arguments.dataset.tag ) ;
			
			datares = structKeyArray(variables.data).filter(function(item) { return hasTag(item, tags) ; });

			if ( arguments.dataset.keyExists( "sort_order") ) {
				sort_field = ListFirst( arguments.dataset.sort_order, " ");
				sort_dir = ListLen(arguments.dataset.sort_order, " ") eq 2 ? ListLast( arguments.dataset.sort_order, " ") : "asc";
			}
			else {
				sort_field = "title";
				sort_dir = "asc";
			}
			
			datares = datares.sort( function (any e1, any e2) { return dataCompare(e1, e2, sort_field, sort_dir); } ); 

			variables.dataSets[arguments.dataset.name] = datares;
		
		}

		return variables.dataSets[arguments.dataset.name];
		
	}

	private boolean function hasTag(required string id, required array tags) {

		for (tag in arguments.tags) {
			if (variables.data[arguments.id].tags.keyExists(tag) ) {
				return true;
			}
		}

		return false;

	}

	private numeric function dataCompare(required string e1, required string e2, required string sort_field, required string sort_dir) {


		val1 = variables.data[arguments.e1][arguments.sort_field];
		val2 = variables.data[arguments.e2][arguments.sort_field];

		switch(arguments.sort_field) {
			case "title":
				temp = compareNoCase(val1, val2);
				break;
			case "sort_order":
				temp = sgn(e1 -e2);
				break;
			case "pubdate":
				temp = dateCompare(val1, val2);
				break;
		}

		if (arguments.sort_field eq "desc") temp = temp * -1;

		return temp;

	}

	// we just return the whole set for this
	public struct function getRecords(required array ID) {

		if (variables.reload) checkStylesChanged();

		return variables.data;
				
	}

	/**
	 * Get full record of data
	 * 
	 */
	public struct function getRecord(required string ID) {

		if (variables.reload) checkStylesChanged();

		return variables.data[arguments.id];
				
	}

}