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

pageContent.css &= application.settingsTest.contentObj.css({});

pageContent.body = "<h2>#pageContent.title#</h2>";
</cfscript>

<cfsavecontent variable="temp">
<div class="test">
	<div class="test-header">Auto grid (fit)</div>
	<div id="testfit"><cfoutput>#gridContent(8)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Auto grid (with fill - expand page to see difference) </div>
	<div id="testfill"><cfoutput>#gridContent(5)#</cfoutput></div>
</div>


<div class="test">
	<div class="test-header">Grid with fixed width cols</div>
	<div id="testfixedwidth"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with fixed number of columns</div>
	<div id="testfix"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with set columns</div>
	<div id="testcolumns"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with set columns (manual class)</div>
	<div ><cfoutput>#gridContent(4)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with set rows</div>
	<div id="testrows"><cfoutput>#gridContent(3)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Grid with named areas</div>
	<div id="testnamed">
		<g class="header">header</g>
		<g class="left">left</g>
		<g class="right">right</g>
		<g class="footer">footer</g>
	</div>
</div>

<div class="test">
	<div class="test-header">Flex</div>
	<div id="testflex"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Flex No Wrap</div>
	<div id="testflexnowrap"><cfoutput>#gridContent()#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Flex Stretch</div>
	<div id="testflexstretch"><cfoutput>#gridContent(5)#</cfoutput></div>
</div>

<div class="test">
	<div class="test-header">Flex align center</div>
	<div id="testflexcenter"><cfoutput>#gridContent(5)#</cfoutput></div>
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

string function gridContent(cells=12, len=255) {
	var html = "";
	var text = application.settingsTest.lorem(arguments.len);
	for (var i = 1 ; i <= arguments.cells; i++) {
		html &= "<g>" & text & "</g>";
	}
	return html;
}
</cfscript>




