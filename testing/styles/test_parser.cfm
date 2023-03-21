<!---

Test parsing of CSS text files

## Synopsis

Just reads a sample stylesheet and passes it to the parser.

--->

<cfscript>
testFile = expandPath("../../sample/_data/styles/sample_layouts.css");
parser = new clikpage.settings.cssParser();
WriteDump(parser.parse(fileRead(testFile)));


</cfscript>