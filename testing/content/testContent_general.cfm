<cfscript>
settingsObj = CreateObject("component", "clikpage.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.contentObj").init(settingsObj=settingsObj);
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));

contentObj.debug = true;

text = contentObj.new(id="text",title="General",content="<p>hello world</p>",image="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg",caption="lorem ipsum");

contentObj.settings(text,styles);

WriteDump(text);
WriteOutput("<pre>" & contentObj.css(text,styles.media) & "</pre>");

html=contentObj.html(text);
WriteOutput( HTMLEditFormat(contentObj.wrapHTML(content=text,html = html)));

text.settings.align = "left";
text.settings.imagewidth = "66%";
WriteOutput("<pre>" & contentObj.css(text,styles.media) & "</pre>");

WriteDump(text);

html=contentObj.html(text);
WriteOutput( HTMLEditFormat(contentObj.wrapHTML(content=text,html = html)));


</cfscript>