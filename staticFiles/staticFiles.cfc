/**
# StaticFiles component

Allows for easy inclusion of static files (js,css) in a web page

See docs/static_files.md

*/

component {
	/**
	 * Constructor
	 *
	 * @staticDef  Struct of static file definitions     
	 * @prefix     The prefix for each item. Change according to whther this is css or js. See setCSS() rather than set these
	 * @suffix     The suffix for each item. See prefix
	 *
	 */
	public staticFiles function init(
		required struct staticDef, 
		string prefix="#chr(9)#<script src=""",
		string suffix="""></script>#chr(13)##chr(10)#"
		) {
		
		variables.prefix = arguments.prefix;
		variables.suffix = arguments.suffix;

		variables.scripts = arguments.staticDef.scripts;
		if (structKeyExists(arguments.staticDef, "packages")) {
			variables.packages = arguments.staticDef.packages;
		}
		else {
			variables.packages = [];
		}

		variables.patternObj = CreateObject( "java", "java.util.regex.Pattern" );
		// generic debug pattern will remove anything between #DEBUG AND /#DEBUG
		// it leaves the comment tags in for the minimiser to deal with.
		variables.debugpattern = variables.patternObj.compile("\##DEBUG.*?\/\##DEBUG",variables.patternObj.MULTILINE + variables.patternObj.UNIX_LINES + variables.patternObj.DOTALL);
		// JS console pattern removes all logging type entries. Use warn or error to leave stuff in
		variables.consolepattern = variables.patternObj.compile("^\s*console\.(log|group.*?|table|time|trace)\(.*?\)\s*;\s*$",variables.patternObj.MULTILINE + variables.patternObj.UNIX_LINES);
	

		/* create lookup caches keyed by name for scripts and packages */

		variables.scriptCache = {};
		variables.packageCache = {};

		try{
			
			for (local.script in variables.scripts) {
				// defaults
				StructAppend(local.script, {"packageExclude":0}, false);
				
				if (! StructKeyExists(local.script,"name")) {
					throw("No name defined for script in json definition");
				}
				variables.scriptCache[local.script.name] = local.script;

				if (local.script.packageExclude && !StructKeyExists(local.script,"min")) {
					throw("No min (the src) defined for script in json definition");
				}
				else if (!local.script.packageExclude && !StructKeyExists(local.script,"min") && !StructKeyExists(local.script,"debug")) {
					throw("No min or debug defined for script in json definition");
				}
			}

			for (local.script in variables.packages) {
				StructAppend(local.script, {"pack":true}, false);
				if (! StructKeyExists(local.script,"name")) {
					throw("No name defined for package in json definition");
				}
				if (local.script.pack && !StructKeyExists(local.script,"min")) {
					throw("No min (the src) defined for package in json definition");
				}
				variables.packageCache[local.script.name] = local.script;

			}
		} 
		catch (any e) {
			local.extendedinfo = {"tagcontext"=e.tagcontext,};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error:" & e.message, 
				detail       = e.detail
			);
		}
		
		return this;
	}	

	/** Set the options to the defaults for css */
	public void function setCss() {
		variables.prefix="#chr(9)#<link rel=""stylesheet"" href=""";
		variables.suffix=""">#chr(13)##chr(10)#";
	}

	public string function getLinks(required struct scripts, boolean debug=false) {
		
		local.packagesIncluded = {};
		local.scriptsInPackage = {};
		local.ret = "";

		/* check if any packages in script def  */
		for (local.scriptname in arguments.scripts) {
			if (StructKeyExists(variables.packageCache, local.scriptname)) {
				local.packagesIncluded[local.scriptname] = 1;
				/* add all scripts from package to list. They may have dependencies */
				local.package = variables.packageCache[local.scriptname];
				for (local.script2 in local.package.scripts) {
					if (StructKeyExists(variables.scriptCache, local.script2)) {
						local.script = variables.scriptCache[local.script2];
						arguments.scripts[local.script2] = 1;	
						if (local.package.pack && !local.script.packageExclude) {
							local.scriptsInPackage[local.script2] = 1;
						}
					}
				}
			}
		}

		/* add required scripts and also note if a script is a package */
		for (local.script in arguments.scripts) {
			if (StructKeyExists(variables.scriptCache, local.script) AND
				StructKeyExists(variables.scriptCache[local.script], "requires")) {
				addRequired(arguments.scripts,variables.scriptCache[local.script].requires);
			}
		}

		for (local.script in variables.scripts) {
			//writeDump(local.script);
			if (StructKeyExists(arguments.scripts, local.script.name)) {
				
				if (arguments.debug) {
					local.scriptSrc = StructKeyExists(variables.scriptCache[local.script.name], "debug") ? variables.scriptCache[local.script.name]["debug"] : variables.scriptCache[local.script.name]["min"];
					local.ret &= variables.prefix &local.scriptSrc  & variables.suffix;
				}
				else if (! StructKeyExists(local.scriptsInPackage, local.script.name) || local.script.packageExclude) {
					local.ret &= variables.prefix & variables.scriptCache[local.script.name]["min"] & variables.suffix;
				}
			}
			
			
		}

		for (local.script in variables.packages) {
			if (StructKeyExists(arguments.scripts, local.script.name)) {
				if (!arguments.debug  && StructKeyExists(local.packagesIncluded,local.script.name) && variables.packageCache[local.script.name].pack) {
					local.ret &= variables.prefix & variables.packageCache[local.script.name]["min"] & variables.suffix;
				}
			}
		}



		return local.ret;

	}

	private void function addRequired(required struct scripts, required string required) {
		for (local.requiredScript in listToArray(arguments.required)) {
			arguments.scripts[local.requiredScript] = 1;
			// check recursion -- NB let it recurse so we get ALL requirements
			if (structKeyExists(variables.scriptCache, local.requiredScript)
				AND structKeyExists(variables.scriptCache[local.requiredScript], "requires")) {
				addRequired(arguments.scripts, variables.scriptCache[local.requiredScript]["requires"]);
			}
		}
	}

	/**
	 * @hint      Load a definition file from disk.
	 *
	 * @defFile  Full path to definition file
	 *
	 */
	public struct function loadDefFile(defFile) {
		if (NOT fileExists(arguments.defFile)) {
			throw("Static files definition file #arguments.defFile# not found");
		}
		local.tempData = fileRead(arguments.defFile);
		try {
			local.jsonData = deserializeJSON(local.tempData);
		}
		catch (Any e) {
			throw("Unable to parse static files definition file #arguments.defFile#");	
		}

		return local.jsonData;
	}

	/**
	 * @hint        Compress packages. Currently using toptal API (see callCompressAPI())
	 *
	 * For each package, concatenate files, compress, and save to file specified
	 *  in "min" field for the package.
	 *
	 * 
	 * 
	 * @type        css|javascript
	 * @overwrite   Allow overwrite of existing file. Recommended to leave this OFF. 
	 *              You should always bump the version
	 * @return      Array of results (result.name, result.saved [won't save if 
	 *              pack=false or all scripts are excluded from packages], 	
	 *              result.filename, result.files)
	 */
	public array function compressPackage(type="css",boolean overwrite=false, struct mappings=[=]) {
		
		local.results = [];
		
		for (local.package in variables.packages) {
			
			local.res = {"name": local.package.name,"saved": false};
			
			if (local.package.pack) {
				
				local.outputFile = filePath(local.package.min,arguments.mappings);
				local.res["filename"] = local.outputFile;
				
				if (FileExists(local.outputFile) AND NOT arguments.overwrite) {
					ArrayAppend(local.results, local.res);
					continue;
				}
				
				local.res["files"]=[];
				local.res["raw"] = 0;// sum total size of raw packages
				// TO DO: check package scripts are in order. Use them if they are
				local.out = "";
				for (local.script in variables.scripts) {
					
					if (ArrayFind(local.package.scripts, local.script.name)) {
						if (!local.script.packageExclude) {
							local.filename = filePath(local.script.min,arguments.mappings);
							if (!FileExists(local.filename)) {
								Throw(message="File #local.filename# not found for script #local.script.name#. Please check mappings if this doesn't make sense.");
							}
							local.res.raw += getFileInfo(local.filename).size;
							local.out &= FileRead(local.filename,"utf-8");
							ArrayAppend(local.res.files, local.filename);
						}
					}
				}
				if (local.out != "") {
					
					local.out =	variables.debugpattern.matcher(local.out).replaceAll("");
					
					try {
						if (arguments.type == "css") {
							local.compressed = minifiyCSS(local.out);
						}
						else {
							local.compressed = minifiyJS(local.out);
						}
					}
					catch (any e) {
						local.extendedinfo = e.keyExists("extendedinfo") ? deserializeJSON(e.extendedinfo) : {};
						StructAppend(local.extendedinfo, {"tagcontext"=e.tagcontext}, false);
						
						throw(
							extendedinfo = SerializeJSON(local.extendedinfo),
							message      = "Unable to minify file #local.outputFile#:" & e.message, 
							detail       = e.detail,
							errorcode    = "compressPackage.2"		
						);
					}

					try {
						FileWrite(local.outputFile, local.compressed, "utf-8");
					}
					catch (any e) {
						throw(
							message      = "Unable to save file #local.outputFile#:" & e.message, 
							detail       = e.detail,
							errorcode    = "compressPackage.1"		
						);
					}
					
					local.res["compressed"] = getFileInfo(local.outputFile).size;;
					local.res["saved"] = true;
				}
			}

			ArrayAppend(local.results, local.res);
			
		}

		return local.results;
	}

	public string function minifiyCSS(required string css) {
		
		return callCompressAPI(input=arguments.css, apiendpoint="https://www.toptal.com/developers/cssminifier/api/raw");
	}

	public string function minifiyJS(required string js) {
		arguments.js = removeJsComments(arguments.js);
		return callCompressAPI(input=arguments.js, apiendpoint="https://www.toptal.com/developers/javascript-minifier/api/raw");
	}

	public string function removeJsComments(required string js) {
		return variables.consolepattern.matcher(arguments.js).replaceAll("");
	}

	private string function callCompressAPI(required string input, required string apiendpoint) {
		local.httpService = new http(method = "POST", charset = "utf-8", url = arguments.apiendpoint,multipart="false");
		local.httpService.addParam(type = "formfield",name="input", value = arguments.input);
		local.httpService.addParam(type = "header", name='content-type', value='application/x-www-form-urlencoded');
	  
		try {
			local.result = httpService.send().getPrefix();
		}
		catch (e) {
			throw(message="unable to connect to compression API",detail=e.message);
		}

		if ((! (StructKeyExists(local.result,"text") && local.result.text)) OR !StructKeyExists(local.result,"filecontent") OR NOT local.result.status_code eq 200)  {

			StructAppend(local.result,{"errordetail":"Unknown error"},false);

			try {
				local.result.filecontent = deserializeJSON(local.result.filecontent);
			}
			catch (any f) {
				//ignore
			}

			local.extendedinfo = {"result"=local.result, "input"=arguments.input};

			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Compression API return an error:" & local.result.errordetail, 
				errorcode    = ""		
			);
		}
		try{
			
		} 
		catch (any e) {
			
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error:" & e.message, 
				detail       = e.detail,
				errorcode    = ""		
			);
		}
				

		return local.result.filecontent;
		
	}

	/**
	 * Get absolute path of a script from a url
	 * @src    src of script -- be default this will be expanded
	 * @mappings  Specified full paths to match agains the src
	 */
	private string function filePath(required string src, required struct mappings) {
		
		var ret = arguments.src;
		for (var mapping in arguments.mappings) {
			if (reFind("^#mapping#", arguments.src)) {
				ret = replace(arguments.src, mapping, arguments.mappings[mapping]);
			}
		}
		return ret;

	}

}
