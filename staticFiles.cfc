/**
 * # StaticFiles component
 * 
 * Allows for easy inclusion of static files (js,css) in a web page
 * 
 * ## Usage
 * 
 * ### Configuration
 * 
 * Configure a definition along the lines of the sample
 * 
 * The script array is the order in which the scripts must appear
 * 
 * Each script entry must have a name and a min entry.
 * 
 * name   Idenitifier
 * min    Minimised version
 * debug  Debug version
 * package Package idenitifier. The pakcage will be used in live mode
 * 
 * ### Use
 * 
 * Instantiate the component in a permanent scope and initialise with the definition and your required prefix/suffix
 * 
 * On requestStart, create a struct in the request scope. Use the request.prc scope 
 * 
 * You can combine this with a string for the onready method, e.g.
 * 
 *     request.prc.js = {static={},onready=""}
 * 
 * To add files of packages, add the struct with a redundant key
 * 
 *     request.prc.js.static["myscript"] = 1
 *     
 * To get the list of scripts for the page, use the `getLinks()` method, e.g.
 * 
 *     writeOutput(application.staticFiles.getLinks(request.prc.js.static));
 *    
 */

component {
	/**
	 * Constructor
	 *
	 * @staticDef  Struct of static file definitions     
	 * @prefix     The prefix for each item. Change according to whther this is css or js
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

		/* create lookup caches keyed by name for scripts and packages */

		variables.scriptCache = {};
		variables.packageCache = {};

		for (local.script in variables.scripts) {
			variables.scriptCache[local.script.name] = local.script;
		}

		for (local.script in variables.packages) {
			variables.packageCache[local.script.name] = local.script;
		}
		

		return this;
	}	

	/** Set the options to the defaults for css */
	public void function setCss() {
		variables.prefix="#chr(9)#<link rel=""stylesheet"" href=""";
		variables.suffix=""">#chr(13)##chr(10)#";
	}

	public string function getLinks(required struct scripts, boolean debug=false) {

		local.packagesRequired = {};
		local.packagesIncluded = {};
		local.ret = "";

		/* check if any packages in script def 
		 */
		for (local.script in arguments.scripts) {
			if (StructKeyExists(variables.packageCache, local.script)) {
				local.packagesIncluded[local.script] = 1;
			}
		}

		/* add all scripts from package to list. They may have dependencies */
		for (local.script in variables.scripts) {
			if (structKeyExists(variables.scriptCache, local.script.name) AND 
				structKeyExists(variables.scriptCache[local.script.name], "package") AND
				structKeyExists(local.packagesIncluded,variables.scriptCache[local.script.name]["package"])) {	
				arguments.scripts[local.script.name] = 1;
			}
		}

		/* add required scripts and also note if a script is a package */
		for (local.script in arguments.scripts) {
			if (structKeyExists(variables.scriptCache, local.script) AND
				structKeyExists(variables.scriptCache[local.script], "requires")) {
				addRequired(arguments.scripts,variables.scriptCache[local.script].requires);
			}
		}

		for (local.script in variables.scripts) {
			//writeDump(local.script);
			if (structKeyExists(arguments.scripts, local.script.name)) {
				if (arguments.debug AND structKeyExists(variables.scriptCache[local.script.name], "debug")) {
					local.ret &= variables.prefix & variables.scriptCache[local.script.name]["debug"] & variables.suffix;
				}
				else if (structKeyExists(variables.scriptCache[local.script.name], "package")) {
					local.packagesRequired[variables.scriptCache[local.script.name].package] = 1;
				}
				else {
					local.ret &= variables.prefix & variables.scriptCache[local.script.name]["min"] & variables.suffix;
				}
			}
			else {
				//writeOutput("#local.script.name#  not found");
			}
		}

		//writeOutput(local.ret);

		for (local.script in variables.packages) {
			if (structKeyExists(local.packagesRequired, local.script.name)) {
				local.ret &= variables.prefix & variables.packageCache[local.script.name].min & variables.suffix;
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

}
