<cfscript>
cfinclude(template="testContent_include.cfm");

defFile = ExpandPath("/_assets/images/buttons.xml");

contentObj.loadButtonDefFile(defFile);

button = contentObj.new(id="hamburger",title="Test button",link="##mainmenu.open",type="button",class="scheme-buttons",content="");

testCS(button);

</cfscript>