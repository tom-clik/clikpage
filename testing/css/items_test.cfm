<!---

# Items testing page

## Notes




## Status

--->

<cfscript>

param name="request.test" default="scheme-articlelist_panels scheme-articlelist_item";

if ( 1 or request.rc.reload OR ! StructKeyExists(application, "cssTestingObject") ) {
	application.cssTestingObject = new cssTestingObject();
}

pageContent = application.cssTestingObject.pageObj.getContent();

pageContent.title = "Articles Testing Page";

css = demoPageCSS();

data=getSampleItems();
list = StructKeyArray(data);

cs = application.cssTestingObject.contentObj.new(id="articlelist",title="Articles",type="articleList", data=list, class=request.test);

styles = duplicate(application.cssTestingObject.styles);
application.cssTestingObject.settingsObj.loadStyleSheet(expandPath("_styles/articleList_test.scss"), styles);

css &= ":root {" & newLine();
css &= application.cssTestingObject.settingsObj.fontVariablesCSS(styles) & newLine();
css &= application.cssTestingObject.settingsObj.colorVariablesCSS(styles) & newLine();
css &= "}" & newLine();

content_css = [];

styling = application.cssTestingObject.contentObj.css(content=cs, styles=styles, debug=true);
content_css.append(styling);
css &= application.cssTestingObject.settingsObj.contentCSS(content_css, styles.media);

pageContent.body = "<h2>#pageContent.title#</h2>";

csdata = application.cssTestingObject.contentObj.display(content=cs ,data=data);

pageContent.body &= csData.html;

// easier to debug if we write out CSS
fileWrite(expandPath("_generated/items_test.css"), css);
application.cssTestingObject.pageObj.addCss(pageContent, "_generated/items_test.css");
application.cssTestingObject.pageObj.addCss(pageContent, "title");

application.cssTestingObject.contentObj.addPageContent(pageContent, csData.pageContent);

writeOutput(application.cssTestingObject.pageObj.buildPage(pageContent));

string function demoPageCSS() {
	var css = ["body {"];
	css.append("background-color: ##f3f3f3;");
	css.append("padding:20px;");
	css.append("}");
	return css.toList(newLine()) & newLine();
}

struct function getSampleItems() {
	data = [=];
	flexmark = new markdown.flexmark(attributes="true",typographic=true);
	files = directoryList(expandPath("../../sample/_data/data/articles"));
	for (filename in files) {
		meta = {};
		html = flexmark.toHtml(fileRead(filename),meta);
		if (meta.keyExists("image")) {
			meta.image = "/images/" & meta.image;
		}
		data[ListFirst(ListLast(filename,"\/"),".")] = meta;
	}

	
	return data;

}

// array function tests()  {
// 		return  [
// 		{"id": "1", "description":"Heading Top"},
// 		{"id": "1a", "description":"Heading Under"},
// 		{"id": "2", "description":"Image Left"},
// 		{"id": "3", "description":"Image right"},
// 		{"id": "2a", "description":"Image Left image space"},
// 		{"id": "3a", "description":"Image right image space"},
// 		{"id": "4", "description":"Heading Under Image Left"},
// 		{"id": "4a", "description":"Heading Under Image Left  image space"},
// 		{"id": "5", "description":"Heading Under Image right"},
// 		{"id": "5a", "description":"Heading Under Image right  image space"},
// 		{"id": "6", "description":"No heading"},
// 		{"id": "7", "description":"No heading left"},
// 		{"id": "8", "description":"No heading right"},
// 		{"id": "9", "description":"Wrap left"},
// 		{"id": "10", "description":"Wrap right"},
// 		{"id": "11", "description":"Heading Under Wrap left"},
// 		{"id": "12", "description":"Heading Under Wrap right"},
// 	];
// }
</cfscript>




