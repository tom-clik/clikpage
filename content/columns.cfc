/*

for wip see testColumns.cfm

It's working of a fashion. None of the heights etc are working. This has got muddled with containerCSS.

The fixed stuff is all a bit ropey as well.

NOT convinced by this at all.

I think we should just use a generic system with grid template areas.

<ubercontainer>
	
	<grid>
		<areas>"header" "topnav content" "footer"</areas>
		<rows>min-content auto min-content</rows>
		<columns>340px auto</columns>
	</grid>
	
	<content>
		<areas>"subcol maincol xcol"</areas>
		<rows>240px auto 140px</rows>
	</content>

</ubercontainer>

If you want to fix stuff then you can do it on the elements themselves.

This was the one instance where the var based stuff wasn't working particularly well. The calcs use the 
fake binary settings for header/footer were rpoey and you can't inspect a value for template rows when
its a var (bug in dev tools).

To generate the class based mechanism you wouldn't need all this data in here, you would have it in an XML file and loop over it.

*/

component extends="contentSection" {

	columns function init(required any contentObj) {
		
		super.init(contentObj=arguments.contentObj);

		this.styleDefs = [
			"site-width":{"type":"dimension","default":"100%"},
			"site-align":{"type":"halignment","default":"center"},
			"xcol-width":{"type":"dimension","default":"15%"},
			"subcol-width":{"type":"dimension","default":"25%"},
			"inner-width":{"type":"dimension","default":"100%"},
			"column-layout":{"type":"text"},
			"row-layout":{"type":"text"},
			"columns-grid-gap":{"type":"dimension"},
			"columns-grid-gap":{"type":"dimension"}
		];
		
		this.settings = {
			"column-layout":"S-M-X",
			"row-layout":"H-T-C-B-F",
			"site-align": "center"
		};

		// css_settings populates this struct and then we write it out
		this.css_vars = [
			"header-fixed-height":"0px",
			"footer-fixed-height":"0px",
			"header-fixed":0,
			"footer-fixed":0,
			"header-display": "block",
			"topnav-display": "block",
			"topnav-position": "static",
			"topnav-top": "0",
			"bottomnav-display": "none",
			"uber-grid-template-columns": "1fr",
			"header-position" = "static",
			"footer-position" = "static",
			"uber-grid-template-areas" = """header""
						 ""topnav""	 
						 ""content"" 
						 ""bottomnav""
						 ""footer"""
		];

		variables.columnData = _columnData();
		
		return this;
	}

	string function css_settings(required string selector, required struct styles) {

		var  css = arguments.selector & " {\n";
		
		local.css_vars = duplicate(this.css_vars);

		StructAppend(local.css_vars, rowSettings(arguments.styles), true);
		StructAppend(local.css_vars, columnSettings(arguments.styles), true);

		for (local.css_var in local.css_vars) {
			css &= "\t--#local.css_var#: " & local.css_vars[local.css_var] & ";\n";
		}

		css &= "\n}\n";

		return css;
	} 

	/**
	 * @hint Convert shorthand row settings into required vars
	 *
	 * There are 5 rows in a default page layout. 
	 *
	 * Header
	 * Top nav
	 * Content
	 * Bottom nav
	 * Footer
	 *
	 * The sofrt hand is row-layout; H-T-C-B-F
	 *
	 * Omit rows you don't want.
	 *
	 * H,T, and F can be fixed. Use HF etc
	 *
	 * TC and can be joined. This is hard wired.
	 *  
	 */
	public struct function rowSettings(required struct styles) {

		// aliases for uber-grid-template-areas, uber-grid-template-rows 
		var uber_areas = "";
		var uber_rows = "";

		var css_vars = {};

		if (StructKeyExists(arguments.styles,"row-layout")) {

			var columns = FindNoCase("TC",arguments.styles["row-layout"]) ? 2 : 1;

			for (var row in ListToArray(arguments.styles["row-layout"],"-")) {
				switch (row) {
					case "HF":
						css_vars["header-fixed-height"] = "var(--header-height)";
						css_vars["header-fixed"] = 1;
						css_vars["header-display"] = "flex";
						css_vars["header-position"] = "fixed";
						break;
					case "H":
						css_vars["header-display"] = "flex";
						css_vars["header-position"] = "static";
						local.row = "header" & (columns eq 2 ? " header" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
					case "TF":case "TP":
						css_vars["topnav-display"] = row eq "TF" ? "flex" : "none";
						css_vars["topnav-position"] = "fixed";
						if (NOT StructKeyExists(arguments.styles, "topnav-width")) {
							css_vars["topnav-width"] = row eq "TF" ? "160px" : "100vw";
						}
						arguments.styles["topnav-height"] = "100vh";
						if (NOT StructKeyExists(arguments.styles, "topnav-height")) {
							css_vars["topnav-height"] = "100vh";
						}
						break;
					case "T":
						css_vars["topnav-display"] = "flex";
						local.row = "topnav" & (columns eq 2 ? " topnav" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
					case "C":
						local.row = "content" & (columns eq 2 ? " content" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "auto", " ");
						break;
					case "TC":
						css_vars["topnav-display"] = "flex";
						uber_areas = ListAppend(uber_areas, """topnav content""", " ");
						uber_rows = ListAppend(uber_rows, "auto", " ");
						if (NOT StructKeyExists(arguments.styles, "topnav-width")
							OR arguments.styles["topnav-width"] eq "auto") {
							arguments.styles["topnav-width"] = "160px";
						}
						css_vars["uber-grid-template-columns"] = "var(--topnav-width) auto";
						break;
					case "B":
						css_vars["bottomnav-display"] = "flex";
						local.row = "bottomnav" & (columns eq 2 ? " bottomnav" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
					case "FF":
						css_vars["footer-fixed-height"] = "var(--footer-fixed-height)";
						css_vars["footer-fixed"] = 1;
						css_vars["footer-display"] = "flex";
						css_vars["footer-position"] = "fixed";
						break;
					case "F":
						css_vars["footer-display"] = "flex";
						css_vars["footer-position"] = "static";
						local.row = "footer" & (columns eq 2 ? " footer" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
				}

			}

			css_vars["uber-grid-template-areas"] = uber_areas;
			css_vars["uber-grid-template-rows"] = uber_rows;

		}

		return css_vars;

	}

	public struct function columnSettings(required struct styles) {

		// aliases for uber-grid-template-areas, uber-grid-template-rows 
		var uber_areas = "";
		var uber_rows = "";

		var css_vars = {};
		if (StructKeyExists(arguments.styles,"column-layout")
			AND StructKeyExists(variables.columnData,arguments.styles["column-layout"])) {
			local.settings = variables.columnData[arguments.styles["column-layout"]];

			for (local.col in ["subcol","xcol"]) {
				if (StructKeyExists(local.settings, local.col)) {
					css_vars[local.col & "-display"] = local.settings[local.col];
				}
			}
			if (StructKeyExists(local.settings, "areas")) {
				css_vars["columns-grid-template-areas"] = local.settings.areas;
			}
			if (StructKeyExists(local.settings, "columns")) {
				css_vars["columns-grid-template-columns"] = local.settings.columns;	
			}
			

		}
		return css_vars;

	}


	private struct function _columnData() {
		return {
			  "M": {
			    "areas": "maincol",
			    "columns": "1fr",
			    "subcol": "none",
			    "xcol": "none"
			  },
			  "M-S": {
			    "areas": "maincol subcol",
			    "columns": "auto  var(--subcolwidth)",
			    "xcol": "none"
			  },
			  "M-S-X": {
			    "areas": "maincol   subcol xcol ",
			    "columns": "auto var(--subcolwidth) var(--xcolwidth)"
			  },
			  "M-SX": {
			    "areas": """maincol subcol"" ""maincol xcol""",
			    "columns": "auto var(--subcolwidth) ",
			    "rows": "min-content auto"
			  },
			  "M-X": {
			    "areas": "maincol xcol",
			    "columns": "auto  var(--xcolwidth)",
			    "subcol": "none"
			  },
			  "M-X-S": {
			    "areas": "maincol xcol  subcol",
			    "columns": "auto  var(--xcolwidth)  var(--subcolwidth)"
			  },
			  "M-XS": {
			    "areas": """maincol xcol"" ""maincol subcol""",
			    "columns": "auto var(--subcolwidth) ",
			    "rows": "min-content auto"
			  },
			  "MS": {
			    "areas": """maincol"" ""subcol""",
			    "columns": "1fr",
			    "xcol": "none"
			  },
			  "MS-X": {
			    "areas": """maincol xcol"" ""subcol xcol""",
			    "columns": "auto var(--xcolwidth) ",
			    "rows": "min-content auto"
			  },
			  "MSX": {
			    "areas": """maincol"" ""subcol"" ""xcol""",
			    "columns": "1fr"
			  },
			  "MX": {
			    "areas": """maincol"" ""xcol""",
			    "columns": "1fr",
			    "subcol": "none"
			  },
			  "MX-S": {
			    "areas": """maincol subcol"" ""xcol subcol""",
			    "columns": "auto  var(--subcolwidth)",
			    "rows": "min-content auto"
			  },
			  "MXS": {
			    "areas": """maincol"" ""xcol"" ""subcol""",
			    "columns": "1fr"
			  },
			  "S-M": {
			    "areas": "subcol maincol",
			    "columns": "var(--subcolwidth) auto",
			    "xcol": "none"
			  },
			  "S-M-X": {
			    "areas": "subcol maincol xcol",
			    "columns": "var(--subcolwidth) auto var(--xcolwidth)"
			  },
			  "S-MX": {
			    "areas": """subcol maincol"" ""subcol xcol""",
			    "columns": "var(--subcolwidth) auto",
			    "rows": "min-content auto"
			  },
			  "S-X-M": {
			    "areas": "subcol xcol maincol",
			    "columns": "var(--subcolwidth) var(--xcolwidth) auto "
			  },
			  "S-XM": {
			    "areas": """subcol xcol"" ""subcol maincol""",
			    "columns": "var(--subcolwidth) auto",
			    "rows": "min-content auto"
			  },
			  "SM": {
			    "areas": """subcol"" ""maincol""",
			    "columns": "1fr",
			    "xcol": "none"
			  },
			  "SM-X": {
			    "areas": """subcol xcol"" ""maincol xcol""",
			    "columns": "auto var(--xcolwidth) ",
			    "rows": "min-content auto"
			  },
			  "SMX": {
			    "areas": """subcol"" ""maincol"" ""xcol""",
			    "columns": "1fr"
			  },
			  "SX-M": {
			    "areas": """subcol maincol"" ""xcol maincol""",
			    "columns": "var(--subcolwidth) auto"
			  },
			  "SXM": {
			    "areas": """subcol"" ""xcol"" ""maincol""",
			    "columns": "1fr"
			  },
			  "X-M": {
			    "areas": "xcol maincol",
			    "columns": "var(--xcolwidth) auto",
			    "subcol": "none"
			  },
			  "X-M-S": {
			    "areas": "xcol maincol subcol",
			    "columns": "var(--xcolwidth) auto  var(--subcolwidth)"
			  },
			  "X-MS": {
			    "areas": """xcol maincol"" ""xcol subcol""",
			    "columns": "var(--xcolwidth) auto",
			    "rows": "min-content auto"
			  },
			  "X-S-M": {
			    "areas": "xcol  subcol maincol",
			    "columns": "var(--xcolwidth)   var(--subcolwidth) auto"
			  },
			  "X-SM": {
			    "areas": """xcol subcol"" ""xcol maincol""",
			    "columns": "var(--xcolwidth) auto",
			    "rows": "min-content auto"
			  },
			  "XM": {
			    "areas": "xcol maincol",
			    "columns": "1fr",
			    "subcol": "none"
			  },
			  "XM-S": {
			    "areas": """xcol subcol"" ""maincol subcol""",
			    "columns": "auto var(--subcolwidth)"
			  },
			  "XMS": {
			    "areas": """xcol"" ""maincol"" ""subcol""",
			    "columns": "1fr"
			  },
			  "XS-M": {
			    "areas": """xcol maincol"" ""subcol maincol""",
			    "columns": "var(--subcolwidth) auto",
			    "rows": "min-content auto"
			  },
			  "XSM": {
			    "areas": """xcol"" ""subcol"" ""maincol""",
			    "columns": "1fr"
			  }
			};
	}

}