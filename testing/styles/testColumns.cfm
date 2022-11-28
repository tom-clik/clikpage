<!---

Preview a layout page with the styling generated by test_styles.cfm

--->

<cfscript>
layoutroot = expandPath("../layouts");

layoutsObj = new clikpage.layouts.layouts(layoutroot);

mylayout = layoutsObj.getLayout("testlayout1/testlayout2");

mylayout.layout.head().append("<style></style>");

divs = addInners(mylayout);

// big question here: how to add grid areas for all divs.
cssTemp = "";

for (div in divs) {
	cssTemp &= "###div# {grid-area:#div#;}" & newLine();
}

mylayout.layout.head().append("<style>#cssTemp#</style>");
mylayout.layout.head().append("<link rel=""stylesheet"" href=""/_assets/css/reset.css"">");
mylayout.layout.head().append("<link rel=""stylesheet"" href=""/_assets/css/images.css"">");
mylayout.layout.head().append("<link rel=""stylesheet"" href=""test_settings.css"">");
mylayout.layout.body().addClass("template-testlayout1").addClass("template-testlayout2");

for (id in ["subcol","xcol"]) {
	cols = mylayout.layout.select("###id#");
	for (col in cols) {
		cols.html("Some content for #id#");
	}
}


// WriteOutput(HtmlCodeFormat(mylayout.layout.html()));
WriteOutput(mylayout.layout.html());

public array function addInners(required layout) {
	
	local.divs = [];
	local.test = arguments.layout.layout.select("div");
	for (local.div in local.test) {
		arrayAppend(local.divs, local.div.id());
	}

	for (local.div in local.divs) {
		local.node = arguments.layout.layout.select("###local.div#");
		local.node.html("<div class='inner'>" & local.node.html() & "</div>");
	}
	local.test = arguments.layout.layout.select("content");	
	for (local.div in local.test) {
		
		local.html = "";
		local.cs = layoutsObj.coldsoup.XMLNode2Struct(local.div);
		
		if (structKeyExists(local.cs, "title")) {
			local.html &= "<h2>" & local.cs.title & "</h2>";
		}
		if (structKeyExists(local.cs, "image")) {
			local.html &= "<figure><img src='" & local.cs.image & "' /></figure>";
		}
		if (structKeyExists(local.cs, "content")) {
			local.html &= "<p>" & local.cs.content & "</p>";
		}
		else if (structKeyExists(local.cs, "type")) {
			local.html &= "<p>" & local.cs.type & " " & local.cs.id & " " & "</p>";
		}

		local.div.tagName("div").html(local.html);
			
	}

	return local.divs;
	
}

</cfscript>


