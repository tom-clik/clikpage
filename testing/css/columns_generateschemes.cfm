<!--- 

# Columns Generate Schems

generate the column schemes file to allow use of e.g.  body.col-MX etc

## Synopsis

Loop over the complete range of permutations for columns and rows in each media query and write out the CSS.



## Notes




## History


--->

<cfscript>
fileout = ExpandPath("_styles/css-autoschemes.css");
columns = deserializeJSON(fileRead("columns_data.json"));

// Get the media sizes from out test styles.
settingsObj = new clikpage.settings.settingsObj(debug=1);
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));

css = "
:root {
	--subcolwidth:160px;
	--xcolwidth:120px;
}
";
//
for (div in "header,subcol,maincol,xcol,content,content_top,content_bottom,footer,topnav,bottomnav,maincol_top,maincol_left,maincol_right,maincol_grid,maincol_bottom,footer_left,footer_right,footer_middle") {
	css &= "###div# {grid-area:#div#}\n";
}

css &= staticCSS();

medialist = structKeyArray(styles.media);
ArrayPrepend(medialist,"main");

for (medium in medialist) {
	
	if (medium != "main") {
		css &= "@media.#medium# {\n";
	}

	for (scheme_id in columns) {
		css &= "." & getClass(medium) & "-" & scheme_id & " ##columns {\n";
		scheme = columns[scheme_id];
		local.areas = scheme.areas;
		if (left(local.areas,1) neq """") {
			local.areas = """" & local.areas & """";
		}
		css &= "\tgrid-template-areas:" & local.areas & ";\n";
		css &= "\tgrid-template-columns:" & scheme.columns & ";\n";
		css &= "}\n";
	}
	
	if (medium != "main") {
		css &= "}\n";
	}	
}

css = settingsObj.outputFormat(css=css,styles=styles);

fileWrite(fileout, css);

writeOutput("written to #fileout#");
</cfscript>

<cfscript>

string function getClass(string medium) {
	switch (arguments.medium) {
		case "main":
			return "col";
			break;
		case "mobile":
			return "mob";
			break;		
		default:
			return	arguments.medium;

	}

}

/** WIP Static css required. */
string function staticCSS() {
	return "
		##columns {
				min-height: 100%;
				display: grid;
				grid-template-areas: ""subcol maincol xcol"";
				grid-gap:5px;
				grid-template-columns: 220px 1fr 140px;
			}
		";
}

</cfscript>
