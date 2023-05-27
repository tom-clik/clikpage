<!--- 

# Colors Test

Colour editing page.

## Status

Not done. Just shows some boxes. 

Really wants to be a JavaScript plugin anyway. 

## History

2022-03-18  THP   rough start

--->

<cfscript>
colors = [
{"name":"darkcolor","value"="006b8a","text"="ffffff"},
{"name":"mediumcolor","value"="007FA3","text"="ffffff"},
{"name":"lightcolor","value"="f7f7f7"},
{"name":"bordercolor","value"="cccccc"},
{"name":"bordercolorplus","value"="dddddd"},
{"name":"rowbg","value"="E7E9EB"},
{"name":"mediumpluscolor","value"="007799","text"="ffffff"},
{"name":"accent","value"="cc3057","text"="ffffff"},
{"name":"reversecolor","value"="hite"},
{"name":"panelbg","value"="4b384c","text"="ffffff"},
{"name":"textcolor","value"="000000","text"="ffffff"},
{"name":"title-color","value"="333333","text"="ffffff"}
];
</cfscript>

<html>
	<head>
		<title>Colors Test</title>

		<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">

		<link rel="stylesheet" type="text/css" href="reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<!--- <link rel="stylesheet" type="text/css" href="_styles/columns_settings.css"> --->
		<style type="text/css">
			<cfoutput>#css(colors)#</cfoutput>
			.colorbox {
				--mingridcol:140px;
				--text-color:unset;
				--border-color:#ccc;
				padding:40px;
			}
			.colorbox div {
				height:80px;
				color: var(--text-color);
				padding:12px;
				border:1px solid  var(--border-color);
			}

		</style>
	</head>

<body>

	<div id="ubercontainer">
		
		<div class="colorbox scheme-grid">

			<cfloop index="color" array="#colors#">
				<cfoutput>
					<div id="#color.name#">#color.name#</div>
				</cfoutput>
			</cfloop>

		</div>

		<textarea rows=8 cols=80>
	<cfoutput>#Processtext(csscolors(colors))#</cfoutput>
		</textarea>

	</div>

	

</body>


</html>


<cfscript>
string function css(required array colors) {

	var  css = "body {\n";
	css &= csscolors(arguments.colors);
	css &= "}\n";
	css &= boxes(arguments.colors);
	
	return ProcessText(css,true);

}


string function csscolors(required array colors, indent = 1) {

	var  css = "";

	for (local.color in colors) {
		css &= "\t--#local.color.name#: ###local.color.value#;\n";
	}

	css =  Replace(css,"\t",RepeatString("\t",arguments.indent));

	return css;
} 


/**
 *  
 */
string function boxes(required array colors, indent = 1) {

	var  css = "";

	for (local.color in colors) {
		css &= "\t###local.color.name# {background-color: var(--#local.color.name#);";
		css &= structKeyExists(local.color, "text") ? "--text-color:###local.color.text#;" : "";
		css &= "}\n";
	}

	css =  Replace(css,"\t",RepeatString("\t",arguments.indent));

	return css;
} 

string function ProcessText(text,boolean debug=true) {
	var tab = arguments.debug ? chr(9) : "";
	var cr = arguments.debug ? chr(13) & chr(10) : "";

	return ReplaceList(arguments.text,"\n,\t","#cr#,#tab#");
}


</cfscript>
