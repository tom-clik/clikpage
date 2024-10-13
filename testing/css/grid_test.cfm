<!---

# Grid testing page

## Notes




## Status

Working now with new pattern

## History



--->

<cfscript>


if ( request.rc.reload OR ! StructKeyExists(application, "cssTestingObject") ) {
	application.cssTestingObject = new cssTestingObject();
}

pageContent = application.cssTestingObject.pageObj.getContent();

pageContent.title = "Grid Testing Page";

pageContent.css = demoPageCSS();

cs = application.cssTestingObject.contentObj.new(id="test",title="Grid",type="grid");

styles = duplicate(application.cssTestingObject.styles);
application.cssTestingObject.settingsObj.loadStyleSheet(expandPath("_styles/grid_test.scss"), styles);

css = [];

for (test in ["testfit","testfill","testfixedwidth","testfix","testcolumns","testrows","testnamed","testflex","testflexnowrap","testflexstretch","testflexcenter"]) {
	cs.id = test;

	styling = application.cssTestingObject.contentObj.css(content=cs, styles=styles, debug=false);
	css.append(styling);
}

pageContent.css &= application.cssTestingObject.settingsObj.contentCSS(css, styles.media);

csdata = application.cssTestingObject.contentObj.display(content=cs);

application.cssTestingObject.contentObj.addPageContent(pageContent, csData.pageContent);

pageContent.body = "<h2>#pageContent.title#</h2>";
</cfscript>

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
pageContent.body &= htmlCodeFormat(pageContent.css);

writeOutput(application.cssTestingObject.pageObj.buildPage(pageContent));

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
	.test-header {
		font-weight: bold;
	}
	.test {
		margin:10px 0;
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
		html &= "<g>" & application.cssTestingObject.lorem(tlen) & "</g>";
	}
	return html;
}
</cfscript>




