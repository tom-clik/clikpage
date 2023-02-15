<!---

Currently a scratchpad. Working towards a complete method for saving a stylesheet.

NEW SYSTEM: 

We have the layout styles in a collection called layouts (a new key of the stylesheet). Each of these can have a set of styling for the layout containers.

The main styles can also have styling for containers but these will apply to everything e.g. colors.

Then we have to write out the styles for all the content sections. How we do this I'm not sure. We need to get every CS from every template.

--->

<cfscript>
layoutsFolder = expandPath("../../sample/_data/layouts");
siteObj = new clikpage.site.site(layoutsFolder=layoutsFolder,mode="live");
sitedata = siteObj.layoutsObj.loadAll();
// styles = siteObj.settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));
styles = siteObj.settingsObj.loadStyleSheet(ExpandPath("../../sample/_data/styles/sample_style.xml"));
outfile = ExpandPath("test_settings.css");

siteObj.contentObj.debug = true;
css = siteObj.contentObj.siteCSS(site=sitedata,styles=styles);

fileWrite(outfile, css);

WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>