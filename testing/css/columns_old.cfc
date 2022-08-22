<!---

ALL MOVED TO content.columns

--->


/*

:root {
	--sitewidth:100%;
	// spanning now set by these. No classes
	--inner-width:100%;
	--subcolwidth:25%;
	--xcolwidth:15%;
	--columns-grid-gap:5px;
	--content-grid-gap:5px;
	--xcol-display:block;
	--subcol-display:block;
	--uber-grid-template-areas: "header"
						 "topnav"	 
						 "content" 
						 "bottomnav"
						 "footer";
	--uber-grid-template-rows: min-content min-content auto min-content min-content;
	--uber-grid-template-columns: 1fr;
	--content-grid-template-areas: "content_top" "content" "content_bottom";
	--content-grid-template-rows: min-content auto min-content;
	--columns-grid-template-areas: "subcol maincol xcol";
	--columns-grid-template-columns: var(--subcolwidth) auto var(--xcolwidth);
	--columns-grid-template-rows: auto;
	--footer-grid-template-areas:"footer_left footer_middle footer_right";
	--footer-grid-template-columns: 33% auto 33%;
	--maincol-grid-template-columns: 1fr 1fr;
	--maincol-grid-gap: var(--columns-grid-gap);
	--header-display: block;
	--footer-display: block;
	--topnav-display: block;
	--bottomnav-display: block;
	--content_top-display: block;
	--content_bottom-display: block;

}

The settings can be used for any viewport.

*/

component extends="test_csbase" {

	columns function init() {

		this.styleDefs = [
			"xcol-width":{"type":"dimension"},
			"subcol-width":{"type":"dimension"},
			"column-layout":{"type":"text"},
			"row-layout":{"type":"text"},
			"columns-grid-gap"{"type":"dimension"}
		];
		
		this.settings = {
			"column-layout":"S-M-X",
			"row-layout":"H-T-C-B-F"
		}

		return this;
	}

	/**
	 * @hint Generate CSS for column layout
	 *
	 * NB  body_class can be used to qualify the selector e.g. template body.layout-main or body.col-MSX
	 *
	 * This gets used when generating single stylesheets for all layouts in a site or for generating the 
	 * scheme based layout file.
	 * 
	 * @styles       Struct of style settings
	 * @body_class   Optional choose to qualify the css selector with a class.
	 */
	string function css(required struct styles, string body_class="") {

		var  css = "";

		local.media = getMedia(arguments.styles);

		for (local.mediumname in local.media) {
			local.medium = local.media[local.mediumname];
			if (StructKeyExists(arguments.styles,local.mediumname)) {
				local.indent = local.mediumname eq 1 ? 1 : 2;
				rowSettings(arguments.styles[local.mediumname]);
				local.css_section = CSSSettings(styles=arguments.styles[local.mediumname],indent=local.indent);
				local.screenSize=[];
				if (local.css_section != "") {
					if (StructKeyExists(local.medium,"min")) {
						ArrayAppend(local.screenSize,"min-width: #local.medium.min#px")
					};
					if (StructKeyExists(local.medium,"max")) {
						ArrayAppend(local.screenSize,"max-width: #local.medium.max#px")
					};
					local.class = arguments.body_class neq "" ? "." & arguments.body_class : "";
					local.css_section = "body#local.class# {\n" & local.css_section & "}\n";
					
					if (ArrayLen(local.screenSize)) {
						local.css_section = "@media screen AND (" & ArrayToList(local.screenSize," AND ") & ") {\n" & local.css_section & "}\n";
					}
					css &= local.css_section;
				}
			}

		}

		return ProcessText(css,true);

	}

	string function CSSSettings(required struct styles, indent = 1) {

		var  css = "";

		for (local.setting in this.settings) {
			if (StructKeyExists(arguments.styles,local.setting) AND arguments.styles[local.setting] != "") {
				css &= "\t--#local.setting#:#arguments.styles[local.setting]#;\n";	
			}	
		}

		if (StructKeyExists(arguments.styles,"column-layout")) {

			switch (arguments.styles["column-layout"]) {
				case "S-M":  case "M-S":case "SM":  case "MS":
					css &= "\t--xcol-display:none;\n";
				break;
				case "M-X": case "X-M":case "MX": case "XM":
					css &= "\t--subcol-display:none;\n";
				break;
				case "M":
					css &= "\t--subcol-display:none;\n";
					css &= "\t--xcol-display:none;\n";
				break;
			}

			switch (arguments.styles["column-layout"]) {
				case "S-MX": case "S-XM":case "M-SX": case "M-XS":case "X-MS": case "X-SM":
				case "SM-X": case "MS-X":case "X-SM": case "X-MS":
				case "XM-S": case "MX-S":
				css &= "\t--columns-grid-template-rows: min-content auto;\n";	
				break;
			}
			css &= "/* column layout #arguments.styles["column-layout"]# */\n";
			switch (arguments.styles["column-layout"]) {
				case "S-M-X":
					css &= "\t--columns-grid-template-areas: ""subcol maincol xcol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) auto var(--xcolwidth);\n";
				break;
				case "S-X-M":
					css &= "\t--columns-grid-template-areas: ""subcol xcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) var(--xcolwidth) auto ;\n";
				break;
				case "X-M-S":
					css &= "\t--columns-grid-template-areas: ""xcol maincol subcol"";\n";
					css &= "\t--columns-grid-template-columns:var(--xcolwidth) auto  var(--subcolwidth);\n";
				break;
				case "X-S-M":
					css &= "\t--columns-grid-template-areas: ""xcol  subcol maincol"";\n";
					css &= "\t--columns-grid-template-columns:var(--xcolwidth)   var(--subcolwidth) auto;\n";
				break;
				case "M-X-S":
					css &= "\t--columns-grid-template-areas: ""maincol xcol  subcol"";\n";
					css &= "\t--columns-grid-template-columns: auto  var(--xcolwidth)  var(--subcolwidth);\n";
				break;
				case "M-S-X":
					css &= "\t--columns-grid-template-areas: ""maincol   subcol xcol "";\n";
					css &= "\t--columns-grid-template-columns:auto var(--subcolwidth) var(--xcolwidth);\n";
				break;
				case "S-M":
					css &= "\t--columns-grid-template-areas: ""subcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) auto;\n";
				break;
				case "M-S":
					css &= "\t--columns-grid-template-areas: ""maincol subcol"";\n";
					css &= "\t--columns-grid-template-columns: auto  var(--subcolwidth);\n";
				break;
				case "X-M":
					css &= "\t--columns-grid-template-areas: ""xcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--xcolwidth) auto;\n";
				break;
				case "M-X":
					css &= "\t--columns-grid-template-areas: ""maincol xcol"";\n";
					css &= "\t--columns-grid-template-columns: auto  var(--xcolwidth);\n";
				break;
				case "MX-S":
					css &= "\t--columns-grid-template-areas: ""maincol subcol"" ""xcol subcol"";\n";
					css &= "\t--columns-grid-template-columns:auto  var(--subcolwidth);\n";
				break;
				case "S-MX":
					css &= "\t--columns-grid-template-areas: ""subcol maincol"" ""subcol xcol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) auto;\n";
				break;
				case "S-XM":
					css &= "\t--columns-grid-template-areas: ""subcol xcol"" ""subcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) auto;\n";
				break;
				case "SX-M":
					css &= "\t--columns-grid-template-areas: ""subcol maincol"" ""xcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) auto;\n";
				break;
				case "M-XS":
					css &= "\t--columns-grid-template-areas: ""maincol xcol"" ""maincol subcol"";\n";
					css &= "\t--columns-grid-template-columns: auto var(--subcolwidth) ;\n";
				break;
				case "M-SX":
					css &= "\t--columns-grid-template-areas: ""maincol subcol"" ""maincol xcol"";\n";
					css &= "\t--columns-grid-template-columns: auto var(--subcolwidth) ;\n";
				break;
				case "X-SM":
					css &= "\t--columns-grid-template-areas: ""xcol subcol"" ""xcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--xcolwidth) auto;\n";
				break;
				case "X-MS":
					css &= "\t--columns-grid-template-areas: ""xcol maincol"" ""xcol subcol"";\n";
					css &= "\t--columns-grid-template-columns: var(--xcolwidth) auto;\n";
				break;
				case "XS-M":
					css &= "\t--columns-grid-template-areas: ""xcol maincol"" ""subcol maincol"";\n";
					css &= "\t--columns-grid-template-columns: var(--subcolwidth) auto;\n";
				break;
				case "XM-S":
					css &= "\t--columns-grid-template-areas: ""xcol subcol "" ""maincol subcol"";\n";
					css &= "\t--columns-grid-template-columns: auto var(--subcolwidth);\n";
				case "MS":
					css &= "\t--columns-grid-template-areas: ""maincol"" ""subcol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "SM":
					css &= "\t--columns-grid-template-areas: ""subcol"" ""maincol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "MX":
					css &= "\t--columns-grid-template-areas: ""maincol"" ""xcol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "SMX":
					css &= "\t--columns-grid-template-areas: ""subcol"" ""maincol"" ""xcol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "SXM":
					css &= "\t--columns-grid-template-areas: ""subcol"" ""xcol"" ""maincol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "MSX":
					css &= "\t--columns-grid-template-areas:  ""maincol"" ""subcol"" ""xcol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "MXS":
					css &= "\t--columns-grid-template-areas: ""maincol"" ""xcol"" ""subcol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "XMS":
					css &= "\t--columns-grid-template-areas: ""xcol"" ""maincol"" ""subcol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "XSM":
					css &= "\t--columns-grid-template-areas: ""xcol"" ""subcol"" ""maincol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;
				case "M":
					css &= "\t--columns-grid-template-areas: ""maincol"";\n";
					css &= "\t--columns-grid-template-columns:1fr;\n";
					break;		
			}

		}

		css =  Replace(css,"\t",RepeatString("\t",arguments.indent));

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
	public void function rowSettings(required struct styles) {

		// aliases for uber-grid-template-areas, uber-grid-template-rows 
		var uber_areas = "";
		var uber_rows = "";
		if (StructKeyExists(arguments.styles,"row-layout")) {

			StructAppend(arguments.styles, {
				"header-fixed-height":"0px",
				"footer-fixed-height:":"0px",
				"header-fixed":0,
				"footer-fixed":0,
				"header-display": "block",
				"topnav-display": "block",
				"topnav-position": "static",
				"topnav-top": "0",
				"bottomnav-display": "none",
				"uber-grid-template-columns": "1fr",
				"header-position" = "static",
				"footer-position" = "static"
			}, true);
				
			var columns = FindNoCase("TC",arguments.styles["row-layout"]) ? 2 : 1;

			for (var row in ListToArray(arguments.styles["row-layout"],"-")) {
				switch (row) {
					case "HF":
						arguments.styles["header-fixed-height"] = "var(--header-height)";
						arguments.styles["header-fixed"] = 1;
						arguments.styles["header-display"] = "flex";
						arguments.styles["header-position"] = "fixed";
						break;
					case "H":
						arguments.styles["header-display"] = "flex";
						arguments.styles["header-position"] = "static";
						local.row = "header" & (columns eq 2 ? " header" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
					case "TF":case "TP":
						arguments.styles["topnav-display"] = row eq "TF" ? "flex" : "none";
						arguments.styles["topnav-position"] = "fixed";
						if (NOT StructKeyExists(arguments.styles, "topnav-width")) {
							arguments.styles["topnav-width"] = row eq "TF" ? "160px" : "100vw";
						}
						arguments.styles["topnav-height"] = "100vh";
						if (NOT StructKeyExists(arguments.styles, "topnav-height")) {
							arguments.styles["topnav-height"] = "100vh";
						}
						break;
					case "T":
						arguments.styles["topnav-display"] = "flex";
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
						arguments.styles["topnav-display"] = "flex";
						uber_areas = ListAppend(uber_areas, """topnav content""", " ");
						uber_rows = ListAppend(uber_rows, "auto", " ");
						if (NOT StructKeyExists(arguments.styles, "topnav-width")
							OR arguments.styles["topnav-width"] eq "auto") {
							arguments.styles["topnav-width"] = "160px";
						}
						arguments.styles["uber-grid-template-columns"] = "var(--topnav-width) auto";
						break;
					case "B":
						arguments.styles["bottomnav-display"] = "flex";
						local.row = "bottomnav" & (columns eq 2 ? " bottomnav" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
					case "FF":
						arguments.styles["footer-fixed-height"] = "var(--footer-fixed-height)";
						arguments.styles["footer-fixed"] = 1;
						arguments.styles["footer-display"] = "flex";
						arguments.styles["footer-position"] = "fixed";
						break;
					case "F":
						arguments.styles["footer-display"] = "flex";
						arguments.styles["footer-position"] = "static";
						local.row = "footer" & (columns eq 2 ? " footer" : "");
						uber_areas = ListAppend(uber_areas, """#local.row#""", " ");
						uber_rows = ListAppend(uber_rows, "min-content", " ");
						break;
				}

			}

			arguments.styles["uber-grid-template-areas"] = uber_areas;
			arguments.styles["uber-grid-template-rows"] = uber_rows;

		}

	}

}