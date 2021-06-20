component {


	public settingsObj function init(debug=false) {

		this.cr = chr(13) & chr(10);
		this.utils = CreateObject("component", "utils.utilsold");	
		this.debug = arguments.debug;

		return this;
	}

	/** Load an XML settings definition */
	public struct function loadStyleSheet(required string filename) {

		if (!FileExists(arguments.filename)) {
			throw("Stylesheet #arguments.filename# not found");
		}

		local.xmlData = this.utils.fnReadXML(arguments.filename,"utf-8");
		local.xml = this.utils.xml2data(local.xmlData);

		return local.xml;

	}

	/** get CSS for general page layout */
	public string function getLayoutCss(required struct settings, boolean debug=this.debug) {

		local.css = "";

		if (StructKeyExists(arguments.settings, "layouts")) {
			for (local.layoutname in arguments.settings.layouts) {
				local.layout = arguments.settings.layouts[local.layoutname];
				local.css &= "body.layout-#local.layoutname# {\n";

				for (local.setting in local.layout) {
					local.css &= "\t--#local.setting#: " & local.layout[local.setting] & ";\n";
				}

				local.css &= "}\n";
			}
		}

		if (arguments.debug) {
			local.css = replace(local.css, "\n", this.cr,"all");
			local.css = replace(local.css, "\t", chr(9),"all");
		}
		else {
			/** to do: rewrite with java regex to avoid cf bugs */
			local.css = replace(local.css, "\t", "","all");
			local.css = replace(local.css, "\n", "","all");
			local.css = REReplace(local.css,"\/\*.*?\*\/","","all");
		}

		return local.css;

	}



}