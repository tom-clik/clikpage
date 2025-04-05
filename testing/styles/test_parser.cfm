<!---

Test parsing of CSS text files

## Synopsis

Just reads a sample stylesheet and passes it to the parser.

--->

<cfscript>
// testFile = expandPath("../../sample/_data/styles/sample_layouts.css");

testFile = expandPath("./sample_schemes.css");
parser = new clikpage.settings.cssParser();
styles = parser.parse(fileRead(testFile));

WriteDump(styles);

</cfscript>