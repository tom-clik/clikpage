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
// writeDump(columns);
settingsObj = new clikpage.settings.settingsObj(debug=1);
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
// writeDump(styles);


css = "
:root {
	--subcolwidth:160px;
	--xcolwidth:120px;
}
";

mediaStr = settingsObj.getMedia(styles);
for (media_name in mediaStr) {
	media = mediaStr[media_name];
	if (media_name != "main") {
		css &= "@media.#media_name# {\n";
	}
	for (scheme_id in columns) {
		css &= "." & getClass(media_name) & "-" & scheme_id & " ##columns {\n";
		scheme = columns[scheme_id];
		local.areas = scheme.areas;
		if (left(local.areas,1) neq """") {
			local.areas = """" & local.areas & """";
		}
		css &= "\tgrid-template-areas:" & local.areas & ";\n";
		css &= "\tgrid-template-columns:" & scheme.columns & ";\n";
		css &= "}\n";
	}
	
	if (media_name != "main") {
		css &= "}\n";
	}	
}

css = settingsObj.outputFormat(css=css,styles=styles);

fileWrite(fileout, css);
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

</cfscript>
