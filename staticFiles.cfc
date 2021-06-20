/**

# StaticFiles component 
 
Allows for easy inclusion of static files (js,css) in a web page

## Documentation

See clikpage.docs.static_files

**/

component {
	/**
	 * Pseudo constructor
	 *
	 * @staticDef  Struct of static file definitions. See loadDefFile() or just desrialize a json file
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

		// Packages are optional
		if (StructKeyExists(arguments.staticDef, "packages")) {
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

	/** Return HTML tags for inclusion in web page */
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

	/** Add all "required" static files as specified in def file */
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
	 * @hint     Load a definition file from disk.
	 *
	 * @defFile  Full path to definition file
	 *
	 */
	public Struct function loadDefFile(defFile) {
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
