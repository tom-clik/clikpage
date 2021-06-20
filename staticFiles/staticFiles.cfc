/**
 * # StaticFiles component
 * 
 * Allows for easy inclusion of static files (js,css) in a web page
 * 
 * ## Usage
 * 
 * ### Configuration
 * 
 * Configure a definition along the lines of the sample. See Scripts and Packages below for details
 * 
 * The script array is the order in which the scripts must appear.

 * ### Use
 *
 * NB this can be used on its own but is designed for use the the pageObject component.
 *
 * If you do want to just use this, you can instantiate the component in a permanent scope and initialise with the definition and your required prefix/suffix
 * 
 * To add files of packages, add to a "set" (a struct with a redundant key), e.g.
 * 
 *     js_static["myscript"] = 1
 *     
 * To get the list of script/style tags for an HTML page, use the `getLinks()` method, e.g.
 * 
 *     getLinks(js_static);
 *
 * To use the "debug" versions (if specified) call the method with  getLinks(js_static,true);
 *
 * #### Scripts
 *
 * Scripts (meaning css or js files) are defined as an array of objects with the following keys
 *
 * :name
 *    The name by which the script is referenced
 * :min
 * 	  src of the production version of the script (usually minimised or such). Can only be omitted if the script is in a bundled package.
 * :debug
 *    The debug version of the script. Can be omitted if a min version is specified. In debug mode, scripts are always included seperately even if in a bundled package
 * :requires
 *     List or array of required scripts. Always include all required scripts even if it's something as common as jquery
 * :packageExclude (boolean)
 *     Always show separate file even if in a package that is bundled. Typically the "min" script will be served from a CDN
 *
 * Note the order of the array is the order the scripts appear in the page.
 * 
 * Sample script entry
 *
 * ```
{
    "debug": "/_assets/js/jquery.validate.js",
    "min": "https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.1/jquery.validate.js",
    "name": "validate",
    "packageExclude": 1,
    "requires": "jquery"
}
```
 *
 * #### Packages
 *
 * Groups of scripts can be defined in packages. These are added in the same way as normal scripts, e.g. for the package defined below:
 *
 * js_static["main"] = 1
 *  
 * These can include scripts like jquery that won't be "bundled". For any given script definition, the packageExclude
 * field can be set to true to ensure the individual script is always used, usually from a CDN.
 *
 * A package can also be set to not to be packed. Otherwise an "min" attribute must be set for the packaged files (the src). Even if all scripts are marked packageExclude you must still supply either pack:false or a "min" src.
 * 
 * The static object can make attempts at packaging using legacy java components but this is
 * off-piste. Gulp or other systems can also be used.
 *  
 * ```
 * packages": [
        {
            "scripts": [
                "jquery",
                "jqueryui",
                "validate",
                "fuzzy",
                "metaforms",
                "datatables",
                "select2"
            ],
            "pack":false,
            "name":"main"
        }
    ]
    ```
 * 
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
			// defaults
			StructAppend(local.script, {"packageExclude":0}, false);
			variables.scriptCache[local.script.name] = local.script;
			if (! StructKeyExists(local.script,"name")) {
				throw("No name defined for script in json definition");
			}
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

		/* check if any packages in script def 
		 */
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
				else if (arguments.debug) {
					local.ret &= "<!--#local.script.name#  not found -->";
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

}
