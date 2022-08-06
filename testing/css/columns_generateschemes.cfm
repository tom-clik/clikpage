<!--- 

# Columns Generate Schems

generate the column shcemes file to allow use of e.g.  body.col-MX etc

## Synopsis

Loop over the complete range of permutations for columns and rows in each media query and write out the CSS

## Notes




## History


--->

<cfscript>
columnsObj = new clikpic._testing.css_tests.columns();

css = "";

for (media in ["main","mid","mobile"]) {
	for (layout in columns()) {
		styles = {};
		styles[media] = {"column-layout"=layout};
		class = getClass(media);
		css &= columnsObj.css(styles,class & "-" & layout);
	}
	
}

fileWrite(ExpandPath("_styles/css-autoschemes.css"), css);
</cfscript>

<cfscript>
array function columns() {
	return ["S-M","M-S","SM","MS","M-X","X-M","MX","XM","M","S-MX","S-XM","M-SX", "M-XS","X-MS","X-SM","SM-X", "MS-X","X-SM", "X-MS",
"XM-S", "MX-S","S-M-X","S-X-M","X-M-S","X-S-M","M-X-S","M-S-X","S-M","M-S","X-M","M-X","MX-S","S-MX","S-XM","SX-M","M-XS",
"M-SX","X-SM","X-MS","XS-M","XM-S","MS","SM","MX","SMX","SXM","MSX","MXS","XMS","XSM","M"];
}

string function getClass(string medium) {
	switch (arguments.medium) {
		case "main":
			return "col";
			break;
		case "mid":
			return "mid";
			break;	
		case "mobile":
			return "mob";
			break;		


	}

}

</cfscript>
