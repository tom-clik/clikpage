<!---

# Grid testing page

## Notes

Trying to simplify this.  What we want is a page that just parses a stylesheet, outputs CSS for each scheme in that stylesheet and then displays the content section with the scheme applied.

## Status



--->

<cfscript>


if (1 OR request.rc.reload OR ! StructKeyExists(application, "settingsTest") ) {
	application.settingsTest = new settingsTest();
}

pageContent = application.settingsTest.pageObj.getContent();

application.settingsTest.addCSTypeContent(pageContent, "grid");

pageContent.title = "Grid Testing Page";
pageContent.css = demoPageCSS();

cs = application.settingsTest.contentObj.new(id="test",title="Grid",type="grid");

styles = duplicate(application.settingsTest.styles);
application.settingsTest.settingsObj.loadStyleSheet(expandPath("_styles/grid_test.css"), styles);

css = [];

for (test in ["testfit","testfill","testfixedwidth","testfix","testcolumns","testrows","testnamed","testflex","testflexnowrap","testflexstretch","testflexcenter"]) {
	cs.id = test;

	styling = application.settingsTest.contentObj.css(content=cs, styles=styles, debug=true);
	css.append(styling);
}



pageContent.css &= application.settingsTest.settingsObj.contentCSS(css, styles.media);


pageContent.body = "<h2>#pageContent.title#</h2>";
</cfscript>

<cfoutput>
<pre>
	#htmlCodeFormat(pageContent.css)#

</pre>

</cfoutput>

<cfsavecontent variable="temp">
<div class="test">
	<div class="test-header">Auto grid (fit)</div>
	<div id="testfit" class="cs-grid"><cfoutput>#gridContent(8)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Auto grid (with fill - expand page to see difference) </div>
	<div id="testfill" class="cs-grid"><cfoutput>#gridContent(5)#</cfoutput></div>
</div>


<div class="test">
	<div class="test-header">Grid with fixed width cols</div>
	<div id="testfixedwidth" class="cs-grid"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with fixed number of columns</div>
	<div id="testfix" class="cs-grid"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with set columns</div>
	<div id="testcolumns" class="cs-grid"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with set rows</div>
	<div id="testrows" class="cs-grid"><cfoutput>#gridContent(3)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with named areas</div>
	<div id="testnamed" class="cs-grid">
		<g class="header">header</g>
		<g class="left">left</g>
		<g class="right">right</g>
		<g class="footer">footer</g>
	</div>
</div>

<div class="test">
	<div class="test-header">Flex</div>
	<div id="testflex" class="cs-grid"><cfoutput>#gridContent(12,20,10)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Flex No Wrap</div>
	<div id="testflexnowrap" class="cs-grid"><cfoutput>#gridContent(12,50,20)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Flex Stretch</div>
	<div id="testflexstretch" class="cs-grid"><cfoutput>#gridContent(5,20,10)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Flex align center</div>
	<div id="testflexcenter" class="cs-grid"><cfoutput>#gridContent(5,20,10)#</cfoutput></div>
</div>
</cfsavecontent>
<cfscript>

pageContent.body &= temp;

writeOutput(application.settingsTest.pageObj.buildPage(pageContent));

string function demoPageCSS() {
	return "body {
				background-color: ##f3f3f3;
				padding:20px;
			}
			g {
		display: inline-block;
		background-color: ##cecece;
		padding:2px;
	}
	/* See named areas test */
	.header {
		grid-area: header;
	}
	.left {
		grid-area: left;
	}
	.right {
		grid-area: right;
	}
	.footer {
		grid-area: footer;
	}
	";
}

string function gridContent(cells=12, len=100, randLen=0) localmode=false {
	html = "";
	
	for (i = 1 ; i <= arguments.cells; i++) {
		tlen =  (arguments.randLen neq 0) ?  RandRange(randLen, arguments.len) : arguments.len;
		html &= "<g>" & application.settingsTest.lorem(tlen) & "</g>";
	}
	return html;
}
</cfscript>




