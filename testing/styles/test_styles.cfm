<!---

Currently a scratchpad. Working towards a complete method for saving a stylesheet.

NEW SYSTEM: 

We have the layout styles in a collection called layouts (a new key of the stylesheet). Each of these can have a set of styling for the layout containers.

The main styles can also have styling for containers but these will apply to everything e.g. colors.

Then we have to write out the styles for all the content sections. How we do this I'm not sure. We need to get every CS from every template.

--->

<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj  = new clikpage.content.content(settingsObj=settingsObj);

// styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));
styles = settingsObj.loadStyleSheet(ExpandPath("../../sample/_data/styles/sample_style.xml"));
fakesite = deserializeJSON(fileRead(ExpandPath("./testsite.json")));

outfile = ExpandPath("test_settings.css");

contentObj.debug = true;
css = contentObj.siteCSS(site=fakesite,styles=styles);

fileWrite(outfile, css);

WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>