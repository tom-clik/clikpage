<cfscript>
cfinclude(template="testContent_include.cfm");

defFile = ExpandPath("/_assets/images/buttons.xml");

contentObj.loadButtonDefFile(defFile);

button = contentObj.new(id="testing",title="Test button",link="##mainmenu.open",type="button",class="scheme-button scheme-buttontest2",content="Testing");

settingsObj.loadStyleSheet(expandPath("../css/_styles/button_test.scss"), styles);

testCS(button);

</cfscript>