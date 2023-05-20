<cfscript>
/*
Include in all css pages
*/

param name="request.rc.reload" type="boolean" default="0";
param name="request.rc.action" default='index';
param name="request.rc.test" default='auto';
param name="request.rc.medium" default='main';

if (request.rc.reload OR ! StructKeyExists(application, "settingsTest") ) {
	application.settingsTest = new settingsTest();
	application.settingsEdit = new clikpage.settings.settingsEdit(
		contentObj = application.settingsTest.contentObj
	);
}

</cfscript>