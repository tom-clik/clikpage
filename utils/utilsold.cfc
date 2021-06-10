<!--- some useful functions to have in the server scope --->
<cfcomponent name="utils">



<cffunction name="init" hint="Optional pseudo constructor. You need this if you are going to use mappings or caching
	for file paths in functions like load settings">
	
	<cfset var local = StructNew()>
	<cfset variables.mappings = {}>
	
	<!--- where we have a mapping for customtags, add that mapping to this object --->
	<cfset local.path = ExpandPath("/customtags/cfscript")>
		
	<cfif DirectoryExists(local.path)>
		<cfset fnAddMapping("utils", local.path)>
	</cfif>
	
    <cfset this.collections =  createObject( "java", "java.util.Collections" )>
        
	<cfset fnSetLog(0)>

	<cfreturn this>
		
</cffunction>


<cffunction name="fnInit" hint="Legacy init function">
	
	<cfset init()>

</cffunction>

<cffunction name="fnThrow" output="true" hint="CFML Throw wrapper">
	<cfargument name="message" type="string" required="false" default="" hint="Message for Exception">
	<cfargument name="detail" type="string" required="false" default="" hint="Detail for Exception">
	<cfargument name="errorCode" type="string" required="false" default="" hint="Error Code for Exception">
	<cfargument name="extendedInfo" type="string" required="false" default="" hint="Extended Info for Exception">
	<cfargument name="object" type="any" hint="Object for Exception">
	<cfargument name="type" type="string" required="false" default="Application" hint="Type for Exception">
	
	<cfthrow type="#arguments.type#" message="#arguments.message#">
	
	<cfif not isDefined("arguments.object")>
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" errorCode="#arguments.errorCode#" extendedInfo="#arguments.extendedInfo#">
	
	<cfelse>
		<cfthrow object="#arguments.object#">
	</cfif>
	
</cffunction>

<cffunction name="fnReThrowExtended" output="true" hint="reThrow error with added information">
	<cfargument name="message" type="string" required="false" hint="Message for Exception">
	<cfargument name="type" type="string" required="false" default="Application" hint="Type for Exception">
	<cfargument name="detail" type="string" required="false" hint="Detail for Exception">
	<cfargument name="errorCode" type="string" required="false" hint="Error Code for Exception">
	<cfargument name="extendedInfo" type="string" required="false" hint="Extended Info for Exception">
	<cfargument name="object" required="true" type="any" hint="Object for Exception">
	
	<cfset structAppend(arguments, duplicate(arguments.object), 0)>
	<cfset structDelete(arguments, "object")>
	<cfthrow attributecollection="#arguments#">
	
</cffunction>

<cffunction name="fnGetFileMapping" output="false" returntype="string" hint="Test whether the file path passed in has a mapping associated with it. Returned the mapped filepath or blank if no mapping is found."
	notes="E.g. if you have a mapping of dev.clikpic.com/testing => C:\inetpub\wwwroot\clikpic\testing then dev.clikpic.com/testing/test.html
	will return C:\inetpub\wwwroot\clikpic\testing\test.html<br><br>">
		
	<cfargument name="filepath" type="string" required="true">
	<cfargument name="returnOriginal" type="boolean" default="false" hint="Annoyingly the original function returned blank(??) set this to true to return original entry if it isn't in a mapping. Much more useful.">
	<cfargument name="cache" type="boolean" required="false" default="1" hint="optionally maintain a cache">

	<cfif arguments.cache AND NOT StructKeyExists(this,"fileMappingCache")>
		<cfset this.fileMappingCache = {}>
	</cfif>

	<cfif NOT arguments.cache OR NOT structKeyExists(this.fileMappingCache,arguments.filepath)>
		<cfset local.retVal = arguments.returnOriginal ? arguments.filepath : "">

		<cfif IsDefined("variables.mappings")>
			<cfset local.root = ListFirst(arguments.filepath,"/\")>
			<cfif structKeyExists(variables.mappings, local.root)>
				<cfset local.retVal = variables.mappings[local.root] & "/" & ListRest(arguments.filepath,"/\")>
			</cfif>
		</cfif>
		
		<cfif arguments.cache>
			<cflock name="filepathCache" type="exclusive" timeout="5">
				<cfset this.fileMappingCache[arguments.filepath] = local.retVal>
			</cflock>
		</cfif>
	<cfelse>
		<cfset local.retVal =this.fileMappingCache[arguments.filepath]>
	</cfif>
	
	<cfreturn local.retVal>
	
</cffunction>

<cffunction name="fnCheckDirectory" output="false" returntype="boolean" hint="Check a directory exists and try to create it if it doesn't">
	
	<cfargument name="filepath" type="string" required="true">
	
	<cfset var mapping = fnGetFileMapping(arguments.filepath)>
	<cfset mapping = mapping eq "" ? arguments.filepath : mapping>
	
	<cfset var retVal = directoryExists(mapping)>

	<cfif NOT retVal>
		<cfdirectory action="create" directory="#mapping#">
	</cfif>
	
	<cfreturn retVal>
	
</cffunction>


<cffunction name="fnGetFileName" output="false" returntype="string" hint="Calls getFileMapping but returns original name if none found">
		
	<cfargument name="filepath" type="string" required="true">
	
	<cfset var sLocal = {}>
	
	<cfset local.filename = fnGetFileMapping(arguments.filepath)>

	<cfreturn (local.filename eq "" ? arguments.filepath : local.filename)>

	
</cffunction>

<cffunction name="fnGetAllMappings" output="true" returntype="Struct" hint="Return all mappings"
	notes="Found some of our stuff e.g. settingsObj had its own mappings functionality. To make sure the mapping definitions
	are consistent, we can get them out of here and add them to those.

	Ideally we will remove all this individual stuff in time and just use these standard methods.">
	
	<cfreturn Duplicate(variables.mappings)>
	
</cffunction>
	
<cffunction name="fnAddMapping" output="false" returntype="boolean" hint="Add a mapping for file path. Returns true on success.">
		
	<cfargument name="mapping" type="string" required="true">
	<cfargument name="filePath" type="string" required="true">
		
	<cfset Local.retVal = 0>
	
	<cfif IsDefined("variables.mappings")>
		<cfset variables.mappings[arguments.mapping] = arguments.filePath>
		<cfset Local.retVal = 1>
	</cfif>

	
	<cfreturn Local.retVal>
	
</cffunction>

<cffunction name="fnGetDirectoryFromFile" output="false" returntype="string" hint="Return the directory from a path">
		
	<cfargument name="filePath" type="string" required="true">
	
	<cfset var sLocal = {}>

	<cfset local.path = fnGetFileMapping(arguments.filePath)>
	<cfif local.path neq "">
		<cfset arguments.filePath = local.path>
	</cfif>

	<cfset local.dir = Reverse(ListRest(Reverse(arguments.filePath),"/\"))>
	
	<cfreturn local.dir>
	
</cffunction>


<cffunction name="fnFileExists" output="false" hint="FileExists that checks in mappings">
	<cfargument name="filepath" type="string" required="true">
	
	<cfset local.filepath = fnGetFileMapping(arguments.filepath)>
	<cfif local.filepath eq "">
		<cfset local.filepath = arguments.filepath>
	</cfif>

	<cfreturn fileExists(local.filepath)>
	
</cffunction>

<!--- note about remote download.

This was the start of an attempt at building a proper distributed resource system, where a reload would update any resources like this that had been
updated. The idea would be that there would be another set of mappings for URLs, and that the system would check the cache times on all these --->

<cffunction name="fnReadFile" output="false"  hint="Load a file from disk. Can load a local file, a mapped file (see fnGetFileMapping()) or a URL.
	A URL can be supplied either with http:// which will force a remote load, or as mapping to a URL which will download the file to
	the mapped location if it doesn't already exist. Eg. if docs.clikpic.com is mapped to c:\docs\clikpic and you specify docs.clikpic.com/development/rubbish.doc, it will
	check the local file system for c:\docs\clikpic\development\rubbish.doc, and if it doesn't exist, will try to download it from http://docs.clikpic.com/development/rubbish.doc (see note above)">
		
	<cfargument name="filepath" type="string" required="true">
	<cfargument name="charset" type="string" required="false" default="utf-8">
	<cfargument name="binary" type="boolean" required="false" default="0">

	
	<cfif Left(arguments.filepath,4) eq "http">
		<!--- no local mapping. get remote file straight via http --->
		<cftry>
		
			<cfhttp url="#arguments.filepath#" throwonerror="yes"></cfhttp>
			<cfset sLocal.fileData = CFHTTP.FileContent>
			<cfcatch>
				<cfthrow type="FileNotFound" message="Unable to get remote file #arguments.filepath#" detail="#cfcatch.message#<br><br>#cfcatch.detail#">
			</cfcatch>
		
		</cftry>
	<cfelse>
		<cfset local.tickCount = getTickCount()>
		<cfset sLocal.filepath = fnGetFileMapping(arguments.filepath,1)>

		<cfset local.mappingTime = getTickCount() - local.tickCount>
		<!--- <cfif local.mappingTime gt 200>
			<cfoutput>utils.fnGetFileMapping() Took #local.mappingTime# to load #arguments.filepath# (see fnReadFile())</cfoutput>
			<cfabort>
		</cfif> --->
		<cfif NOT FileExists(sLocal.filepath)>
			<cftry>
				<cfhttp url="http://#arguments.filepath#" file="#sLocal.filepath#" throwonerror="yes"></cfhttp>
				<cfcatch>
					<cfthrow type="FileNotFound" message="Unable to download remote file #arguments.filepath# [#sLocal.filepath#]" detail="#cfcatch.message#<br><br>#cfcatch.detail#">
				</cfcatch>
			</cftry>
		</cfif>

		<cfif arguments.charset neq "" AND NOT arguments.binary>
			<cffile action="READ" file="#sLocal.filepath#" variable="sLocal.fileData" charset="#arguments.charset#">
		<cfelse>
			<cfset local.readAction = (arguments.binary ? "readbinary" : "read")>
			<cffile action="#local.readAction#" file="#sLocal.filepath#" variable="sLocal.fileData">
		</cfif>
		
	</cfif>
	
	<cfreturn sLocal.fileData>
	
</cffunction>

<cffunction name="fnReadXML" output="false" returntype="string" hint="Load an XML file from disk and parse it.">
		
	<cfargument name="filepath" type="string" required="true" hint="file path.  See notes for fnReadFile()">
	
	<cfset var sLocal = {}>
		
	<cfset sLocal.fileData = fnReadFile(arguments.filePath)>
	<!--- unicode 0x1f 'Unit Separator' is not valid in XML - replace with tab --->
	<!--- http://stackoverflow.com/questions/6693153/what-is-character-0x1f --->
	<cfset sLocal.fileData = reReplace(sLocal.fileData, "\x1f", "	", "all")>
	<cftry>
		<cfset sLocal.XMLData = XmlParse(sLocal.fileData)>
		<cfcatch>
			<cfthrow message="Unable to parse XML file" detail="fnReadXML():Unable to parse file #arguments.filepath#<br><br>#cfcatch.message#<br><br>#cfcatch.detail#">
		</cfcatch>
     </cftry>
			
	<cfreturn sLocal.XMLData>
	
</cffunction>

<cffunction name="FileSizeFormat" output="false" hint="Return a formatted file size given an integer number of bytes (e.g. 80000 -> 80kb)" returntype="string">
	<cfargument required="yes" name="size" type="numeric" hint="Size in bytes">
	<cfargument required="no" name="sf" default="3" type="numeric" hint="Significant figures for result">
	
	<cfscript>
		if (size lt 1000) {
			return "#SigFigs(size,sf)#b";
		}
		else if (size lt 1000000) {
			size = size / 1000;
			return "#SigFigs(size,sf)#Kb";
		}
		
		else if (size lt 1000000000) {
			size = size / 1000000;
			return "#SigFigs(size,sf)#Mb";
		}
		else {
			size = size / 1000000000;
			return "#SigFigs(size,sf)#Gb";
		}
	</cfscript>

</cffunction>

<cffunction name="SigFigs" output="false" hint="Return a number with only given number of significant figures" returntype="string">
	<cfargument required="yes" name="number" type="numeric" hint="Size in bytes">
	<cfargument required="yes" name="sf" type="numeric" hint="Significant figures for result">
	
	<cfscript>
	var result = "";
	var afterpoint = 0;
	var digit = "";
	var i = 1;
	
	for (; i lte Len(arguments.number); i = i + 1) {
		
		digit = Mid(arguments.number,i,1);
		if (digit eq ".") {
			result = result & ".";
			afterpoint = 1;
		}
		else {
			if (arguments.sf gt 0) {
				result = result & digit;
				arguments.sf = arguments.sf - 1;
			}
			else if (NOT afterpoint) {
				result = result & "0";
			}
		}
	}
	
	return result;
	</cfscript>
</cffunction>

<cffunction name="convertStructToLower" access="public" returntype="any">
    <cfargument name="st" required="true" type="any" hint="in practice: struct or array">

    <cfset var aKeys = false>
    <cfset var stN = false>
    <cfset var i= 0>
    <cfset var ai= 0>

    <cfif isArray(arguments.st)>
    	<cfset stN = []>
    	<cfloop array="#arguments.st#" index="i">
    		<cfset arrayAppend(stN, convertStructToLower(i))>
    	</cfloop>
    <cfelseif isStruct(arguments.st)>
    	<cfset aKeys = structKeyArray(arguments.st)>
    	<cfset stN = structNew()>

	    <cfloop array="#aKeys#" index="i">
	        <cfif isStruct(arguments.st[i])>
	            <cfset stN['#lCase(i)#'] = convertStructToLower(arguments.st[i])>
	        <cfelseif isArray(arguments.st[i])>
	            <cfloop from=1 to="#arraylen(arguments.st[i])#" index="ai">
	                <cfif isStruct(arguments.st[i][ai])>
	                    <cfset arguments.st[i][ai] = convertStructToLower(arguments.st[i][ai])>
	                <cfelse>
	                    <cfset arguments.st[i][ai] = arguments.st[i][ai]>
	                </cfif>
	            </cfloop>
	            <cfset stN['#lcase(i)#'] = arguments.st[i]>
	        <cfelse>
	            <cfset stN['#lcase(i)#'] = arguments.st[i]>
	        </cfif>
	    </cfloop>
    <cfelse>
    	<cfthrow message="Must provide array or struct for convertStructToLower">
    </cfif>
    <cfreturn stn>
</cffunction>

	
	
<cffunction name="XmlAppend" access="public" returntype="any" output="false"
	hint="Copies the children of one node to the node of another document. Returns appended XML.">
 
	<cfargument name="NodeA" type="any" required="true" hint="The node whose children will be added to.">
	<cfargument name="NodeB" type="any" required="true" hint="The node whose children will be copied to another document.">
 
	<cfset var LOCAL = StructNew() >
 
	<!---
		Get the child nodes of the originating XML node.
		This will return both tag nodes and text nodes.
		We only want the tag nodes.
	--->
	<cfset LOCAL.ChildNodes = ARGUMENTS.NodeB.GetChildNodes() >
 
	<cfloop index="LOCAL.ChildIndex" from="1" to="#LOCAL.ChildNodes.GetLength()#" step="1">
 
		<!--- Remember that the child nodes NodeList starts with
			index zero. Therefore, we must subtract one
			from out child node index.
		--->
		<cfset LOCAL.ChildNode = LOCAL.ChildNodes.Item( JavaCast("int",(LOCAL.ChildIndex - 1) ) ) >
 
		<!---
			Import this noded into the target XML doc. If we
			do not do this first, then COldFusion will throw
			an error about us using nodes that are owned by
			another document. Importing will return a reference
			to the newly created xml node. The TRUE argument
			defines this import as DEEP copy.
		--->
		<cfset LOCAL.ChildNode = ARGUMENTS.NodeA.GetOwnerDocument().ImportNode( LOCAL.ChildNode,JavaCast( "boolean", true ) ) >
		
		<cfset ARGUMENTS.NodeA.AppendChild( LOCAL.ChildNode ) >
 
	</cfloop>
 
	<cfreturn ARGUMENTS.NodeA >
</cffunction>
	
<cfscript>
/**
* Makes a row of a query into a structure.
*
* @param query      The query to work with.
* @param row      Row number to check. Defaults to row 1.
* @return Returns a structure.
* @author Nathan Dintenfass (nathan@changemedia.com)
* @version 1, December 11, 2001
*/
function queryRowToStruct(query){
    //by default, do this to the first row of the query
    var row = 1;
    //a var for looping
    var ii = 1;
    //the cols to loop over
    var cols = listToArray(arguments.query.columnList);
    //the struct to return
    var stReturn = structnew();
    //if there is a second argument, use that for the row number
    if(arrayLen(arguments) GT 1)
        row = arguments[2];
    //loop over the cols and build the struct from the query row    
    for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
        stReturn[cols[ii]] = arguments.query[cols[ii]][row];
    }        
    //return the struct
    return stReturn;
}

/**
* Converts a query object into a structure of structures accessible by its primary key.
* 
* Ifthere is cust one other column, returns simple values as keys
*
* @param theQuery      The query you want to convert to a structure of structures.
* @param primaryKey      Query column to use as the primary key.
* @return Returns a structure.
* @author Shawn Seley (shawnse@aol.com)
* @version 1, March 27, 2002
*/
function QueryToStructOfStructures(theQuery, primaryKey,removeKey=0){
var theStructure = structnew();

var cols = [];

var row = 1;
var thisRow = "";
var col = 1;

for (local.check in getMetaData(arguments.theQuery)) {
	// remove primary key from cols listing
	if (NOT Arguments.removeKey OR  (local.check.name neq arguments.primaryKey)) {
		ArrayAppend(cols, local.check.name);	
	}
}

for(row = 1; row LTE theQuery.recordcount; row = row + 1){
	if (arraylen(cols) gt 1) {
		thisRow = structnew();
		for(col = 1; col LTE arraylen(cols); col = col + 1){
			thisRow[cols[col]] = theQuery[cols[col]][row];
		}
		theStructure[theQuery[primaryKey][row]] = duplicate(thisRow);
	}
	else {
		theStructure[theQuery[primaryKey][row]] = theQuery[cols[1]][row];
	}
}
return(theStructure);
}



/**
* Recursive functions to compare structures and arrays.
* Fix by Jose Alfonso.
*
* @param LeftStruct      The first struct. (Required)
* @param RightStruct      The second structure. (Required)
* @return Returns a boolean.
* @author Ja Carter (ja@nuorbit.com)
* @version 2, October 14, 2005
*/
function structCompare(LeftStruct,RightStruct) {
    var result = true;
    var LeftStructKeys = "";
    var RightStructKeys = "";
    var key = "";
    
    //Make sure both params are structures
    if (NOT (isStruct(LeftStruct) AND isStruct(RightStruct))) return false;

    //Make sure both structures have the same keys
    LeftStructKeys = ListSort(StructKeyList(LeftStruct),"TextNoCase","ASC");
    RightStructKeys = ListSort(StructKeyList(RightStruct),"TextNoCase","ASC");
    if(LeftStructKeys neq RightStructKeys) return false;    
    
    // Loop through the keys and compare them one at a time
    for (key in LeftStruct) {
        //Key is a structure, call structCompare()
        if (isStruct(LeftStruct[key])){
            result = structCompare(LeftStruct[key],RightStruct[key]);
            if (NOT result) return false;
        //Key is an array, call arrayCompare()
        } else if (isArray(LeftStruct[key])){
            result = arrayCompare(LeftStruct[key],RightStruct[key]);
            if (NOT result) return false;
        // A simple type comparison here
        } else {
            if(LeftStruct[key] IS NOT RightStruct[key]) return false;
        }
    }
    return true;
}

/**
 * Recursive functions to compare arrays and nested structures.
 * 
 * @param LeftArray 	 The first array. (Required)
 * @param RightArray 	 The second array. (Required)
 * @return Returns a boolean. 
 * @author Ja Carter (ja@nuorbit.com) 
 * @version 1, September 23, 2004 
 */
function arrayCompare(LeftArray,RightArray) {
	var result = true;
	var i = "";
	
	//Make sure both params are arrays
	if (NOT (isArray(LeftArray) AND isArray(RightArray))) return false;
	
	//Make sure both arrays have the same length
	if (NOT arrayLen(LeftArray) EQ arrayLen(RightArray)) return false;
	
	// Loop through the elements and compare them one at a time
	for (i=1;i lte arrayLen(LeftArray); i = i+1) {
		//elements is a structure, call structCompare()
		if (isStruct(LeftArray[i])){
			result = structCompare(LeftArray[i],RightArray[i]);
			if (NOT result) return false;
		//elements is an array, call arrayCompare()
		} else if (isArray(LeftArray[i])){
			result = arrayCompare(LeftArray[i],RightArray[i]);
			if (NOT result) return false;
		//A simple type comparison here
		} else {
			if(LeftArray[i] IS NOT RightArray[i]) return false;
		}
	}
	
	return true;
}

function isInt(varToCheck){
	return isNumeric(arguments.varToCheck) and round(arguments.varToCheck) is arguments.vartoCheck;
}

function isPosInt(varToCheck){
	return isNumeric(arguments.varToCheck) and round(arguments.varToCheck) is arguments.vartoCheck And arguments.vartoCheck gt 0;
}


/**
* Converts Boolean values to either True or False.
*
* @param exp      value (expression) you want converted to True/False.
* @author Rob Brooks-Bilson and Raymond Camden (rbils@amkor.com, rbils@amkor.comray@camdenfamily.com)
* @version 1, January 29, 2002
*/
function TrueFalseFormat(exp){
if (arguments.exp) return true;
return false;
}


/**
* Add the results of a query of a many-to-many join table to a single
* column of another query as a list
*  
*
* @param query1      The query to add column to (referred to as main query) (Required)
* @param joinQuery    The join query (must have two columns, one of which must be the foreign key NB the name of the value column is derived from the columnlist if not specified) (Required)
* @param primaryKey    name of primary key column in main query (Required)
* @param columnName    name of column to add to first query (Required)
* @param foreignKey    name of foreign key column in join query (if not same as primary key of main query)
* @param valueColumn   name of values column in join query if there are not just two columns in the query
* @return void.
* @author Tom Peer
* @version 1, Nov 27 2009
*/

</cfscript>

<cffunction name="fnAddJoinValuesToQuery" output="yes" returntype="void">
	<cfargument name="query1" type="query" required="true">
	<cfargument name="joinQuery" type="query" required="true">
	<cfargument name="primaryKey" type="string" required="true">
	<cfargument name="columnName" type="string" required="true">
	<cfargument name="foreignKey" type="string" required="false" default="#arguments.primaryKey#">
	<cfargument name="valueColumn" type="string" required="false">
	<cfargument name="addSpaces" type="boolean" required="false" default="false">
	
	<cfset var sLocal = StructNew()>
	<!--- Create a struct of join value lists keyed by the foreign key --->
	<cfset sLocal.joinVals = StructNew()>
	
	<!--- work out the column name of the values by deleting the foreign key from
	the column list --->
	<cfset sLocal.temp = ListFindNoCase(arguments.joinQuery.columnList,arguments.foreignKey)>
	<cfif NOT sLocal.temp>
		<cfthrow message="foreign key [#arguments.foreignKey#] not found in column list for join query">
	</cfif>
	
	<cfif NOT IsDefined("arguments.valueColumn")>
		<cfif NOT ListLen(arguments.joinQuery.columnList) eq 2>
			<cfthrow message="Join query must have just two columns if no valueColumn specified">
		</cfif>
		
		<cfset arguments.valueColumn = ListDeleteAt(arguments.joinQuery.columnList,sLocal.temp)>
	</cfif>
	<!--- loop over the join values to populate struct --->
	<cfloop query="arguments.joinQuery">
		<cfset sLocal.key = arguments.joinQuery[arguments.foreignKey]>
		<cfset sLocal.value = arguments.joinQuery[arguments.valueColumn]>
		<cfif NOT StructKeyExists(sLocal.joinVals,sLocal.key)>
			<cfset sLocal.joinVals[sLocal.key] = sLocal.value>
		<cfelse>
			<cfif arguments.addSpaces>
				<cfset sLocal.joinVals[sLocal.key] = ListAppend(sLocal.joinVals[sLocal.key],' '&sLocal.value)>
			<cfelse>
				<cfset sLocal.joinVals[sLocal.key] = ListAppend(sLocal.joinVals[sLocal.key],sLocal.value)>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- now loop over the main query and add the column
	[first create an array for each row and then
	use the queryAddcolumn function] --->	
	<cfset sLocal.columnNew = ArrayNew(1)>
	<cfloop query="arguments.query1">
		<cfset sLocal.key = arguments.query1[arguments.primaryKey]>
		<cfset sLocal.value = "">
		<cfif StructKeyExists(sLocal.joinVals,sLocal.key)>
			<cfset sLocal.value =sLocal.joinVals[sLocal.key]>
		</cfif>
		<cfset ArrayAppend(sLocal.columnNew,sLocal.value)>
	</cfloop>
	
	<cfset sLocal.columnNum = QueryAddColumn(arguments.query1,arguments.columnName,"VarChar",sLocal.columnNew)>
	
</cffunction>
 	
<cffunction name="fnDeepStructAppend" output="false" returntype="void" hint="Appends the second struct to the first.">
	
	<cfargument name="struct1" type="struct" hint="Struct to which values from struct2 are appended.">
	<cfargument name="struct2" type="struct" hint="Append these values to struct1.">
	<cfargument name="overwrite" default="true" required="false" hint="Whether to overwrite keys that already exist in struct1">
	<!--- NB overwrite=false used to only work at first level - if this behaviour is required, use overwrite=false,overwriteDeep=false --->
	<cfargument name="overwriteDeep" default="#arguments.overwrite#" required="false" hint="Whether to overwrite keys that already exist in struct1 when recursing">
	
	<cfset var sLocal = StructNew()>
	
	<cfscript>
	for(sLocal.key IN arguments.struct2){
		if(StructKeyExists(arguments.struct1,sLocal.key) AND 
			IsStruct(arguments.struct2[sLocal.key]) AND 
			IsStruct(arguments.struct1[sLocal.key])){
			fnDeepStructAppend(arguments.struct1[sLocal.key],arguments.struct2[sLocal.key],arguments.overwriteDeep);
		}
		else if (arguments.overwrite OR NOT StructKeyExists(arguments.struct1,sLocal.key)){
			arguments.struct1[sLocal.key] = Duplicate(arguments.struct2[sLocal.key]);
		}
	}
	</cfscript>

</cffunction>

<cffunction name="fnStructOR" output="false" returntype="void" hint="Takes two structs with boolean values and does an OR operation on the keys. One deep only. REMOVES NON Boolean">
	
	<cfargument name="struct1" hint="Struct to which values from struct2 are compared.">
	<cfargument name="struct2" hint="Compare these values to struct1.">
	
	<cfset var sLocal = StructNew()>
	
	<cfscript>
	for(sLocal.key IN arguments.struct2){
		if (isBoolean(arguments.struct2[sLocal.key])) {
			if(NOT StructKeyExists(arguments.struct1,sLocal.key)) {
				arguments.struct1[sLocal.key] = 1 AND arguments.struct2[sLocal.key];
			}
			else if (isBoolean(arguments.struct1[sLocal.key])) {
				arguments.struct1[sLocal.key] = arguments.struct1[sLocal.key] OR arguments.struct2[sLocal.key];
			}
			else {
				StructDelete(arguments.struct1,sLocal.key);
			}
		}
		else {
			StructDelete(arguments.struct1,sLocal.key);
		}
	}
	</cfscript>

</cffunction>

<cffunction name="fnStructClean" output="false" returntype="void" hint="Remove keys from one struct that aren't in a second one">
	
	<cfargument name="struct1" hint="Struct to be cleaned">
	<cfargument name="struct2" hint="These keys can be present in struct one">
	
	<cfset var sLocal = StructNew()>
	
	<cfscript>
	for(sLocal.key IN arguments.struct1){
		if(NOT StructKeyExists(arguments.struct2,sLocal.key)) {
			StructDelete(arguments.struct1,sLocal.key);
		}
	}
	</cfscript>

</cffunction>

<cffunction name="StructRefresh" output="false" returntype="void" hint="Struct append but only uses existing keys.">
	
	<cfargument name="struct1" hint="Struct to be updated">
	<cfargument name="struct2" hint="Values to overwrite originals">
	
	<cfset var sLocal = StructNew()>
	
	<cfscript>
	for(sLocal.key IN arguments.struct1){
		if(StructKeyExists(arguments.struct2,sLocal.key)) {
			if( isStruct(arguments.struct1[sLocal.key]) AND isStruct(arguments.struct2[sLocal.key]) ) {
				StructRefresh(arguments.struct1[sLocal.key], arguments.struct2[sLocal.key]);
			} else {
				arguments.struct1[sLocal.key] = Duplicate(arguments.struct2[sLocal.key]);
			}
		}
	}
	</cfscript>

</cffunction>

<!--- 
	* Author: Ben Nadel (http://www.bennadel.com)
 --->
<cffunction name="StructCreate"
	access="public"
	returntype="struct"
	output="false"
	hint="Creates a struct based on the argument pairs.">
 
	<!--- Define the sLocal scope. --->
	<cfset var sLocal = StructNew()>
 
	<!--- Create the target struct. --->
	<cfset sLocal.Struct = StructNew()>
 
	<!--- Loop over the arguments. --->
	<cfloop collection="#ARGUMENTS#" item="sLocal.Key">
		
		<!--- Set the struct pair values. --->
		<cfset sLocal.Struct[ sLocal.Key ] = ARGUMENTS[ sLocal.Key ]>
		
	</cfloop>
 
	<!--- Return the resultant struct. --->
	<cfreturn sLocal.Struct />
	
</cffunction>

<cffunction name="fnHtmlEditFormat" returntype="Any" output="false" hint="Define function to set all values in a struct to HTML format.">
		
	<cfargument name="value" type="Any" hint="String or struct to convert to HtmlEditFormat">
	
	<cfset var i = false>
	
	<cfif IsStruct(arguments.value)>
		<cfloop collection="#arguments.value#" item="i">
			<cfif IsStruct(arguments.value[i])>
				<cfset arguments.value[i] = fnHtmlEditFormat(arguments.value[i])>
			<cfelse>
				<cfset arguments.value[i] = HtmlEditFormat(arguments.value[i])>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset arguments.value = HtmlEditFormat(arguments.value)>
	</cfif>
	
	<cfreturn arguments.value>
	
</cffunction>

<cffunction name="ListRemoveDuplicates" returntype="string" output="false" hint="Takes a list argument and returns that list with the duplicates removed.">
	
	<cfargument name="list" type="string" required="true" hint="A list to remove the duplicates from.">
	<cfargument name="delimiters" type="string" required="false" default=",">
	<cfargument name="processedVals" type="struct" required="false" default="#StructNew()#" hint="You can pass in an empty struct to return counts of items in list or even pass in some values - any item defined in the struct will be omitted from the returned list">
	
	<cfset var i = 0>
	<cfset var retVal = "">
	
	<cfloop list="#arguments.list#" index="i" delimiters="#arguments.delimiters#">
		<cfif NOT StructKeyExists(arguments.processedVals,i)>
			<cfset retVal = ListAppend(retVal,i)>
			<cfset arguments.processedVals[i]= 1>
		<cfelse>
			<cfset arguments.processedVals[i] += 1>
		</cfif>
		
	</cfloop>
	
	<cfreturn retVal>
	
</cffunction>

<cffunction name="fnParseIniFile" returntype="struct" output="false" hint="Parses an ini file and returns values in a struct (or struct of struct keyed by section name if no section attribute is specified)">
	
	<cfargument name="ini_file" type="string" required="true" hint="File to parse">
	<cfargument name="section" type="string" required="no" hint="Section to parse values for. If no section is specified, the return struct is a struct of structs keyed by the section names">
	
    <cfset var settings = StructNew()>
	<cfset var sections = false>
	<cfset var sectionList = false>
	<cfset var sectionName = false>
	<cfset var dataNames = false>
	<cfset var key = false>	
	<cfset var tmpSettings = StructNew()>
	
	<cfif NOT FileExists(arguments.ini_file)>
		<cfthrow message="Unable to find ini file #arguments.ini_file#">
	</cfif>

	<cfset local.rawtext = fnReadFile(arguments.ini_file)>

	<cfset local.section = "">
	<cfloop index="local.line" list="#local.rawText#" delimiters="#chr(13)##chr(10)#">
		<cfif Left(trim(local.line),1) eq ";" or Left(trim(local.line),1) eq "##">
			<cfcontinue>
		<cfelseif Left(trim(local.line),1) eq "[">
			<cfset local.section = ListFirst(local.line,"[]")>
		<cfelse>
			<cfif local.section eq "">
				<cfthrow message="Incorrect ini file definition #arguments.ini_file#">
			</cfif>
			<cfif NOT structKeyExists(settings,local.section)>
				<cfset settings[local.section] = {}>
			</cfif>
			
			<cfset settings[local.section][ListFirst(trim(local.line),"=")] = ListRest(local.line,"=")>
		</cfif>
	</cfloop>

	<cfloop item="sectionName" collection="#settings#">
		<cfset checkSettingsInheritance(settings[sectionName],settings)>
		
	</cfloop>
    
    <cfif IsDefined("arguments.section")>
    	<cfif NOT StructKeyExists(settings, arguments.section)>
            <cfthrow message="Section ## not found in file #arguments.ini_file#">
        </cfif>
        <cfset settings  = settings[arguments.section]>
    </cfif>
    
	<cfreturn settings>

</cffunction>

<cffunction name="checkSettingsInheritance">
	<cfargument name="section">
	<cfargument name="settings">
	<cfif StructKeyExists(arguments.section, "inherit")>
        <cfloop index="local.sectionName" list="#arguments.section["inherit"]#">
            <cfset checkSettingsInheritance(arguments.settings[local.sectionName],arguments.settings)>
            <cfset StructAppend(arguments.section,settings[local.sectionName],false)>
            <cfset StructDelete(arguments.section, "inherit")>
        </cfloop>
    </cfif>
</cffunction>


<cffunction name="fnListDelete" returntype="string" output="false" hint="Takes a list and a list element and deletes the first instance of that element from the list.">
	
	<cfargument name="list" type="string" required="true" hint="List from which to delete the element.">
	<cfargument name="list_element" type="string" required="true" hint="The element to delete from the list.">
	<cfargument name="delimiters" type="string" required="false" default=",">
	
	<cfset var position = false>
	
	<cfset position = ListFind(arguments.list,arguments.list_element,arguments.delimiters)>
	<cfif position>
		<cfset arguments.list = ListDeleteAt(arguments.list,position,arguments.delimiters)>
	</cfif>
	
	<cfreturn arguments.list>
	
</cffunction>

<cffunction name="fnListAlter" output="false" returntype="string" hint="Takes two lists, one with '+' or '-' in front of the properties, and appends or deletes entries and returns the ammended list.">
	
	<cfargument name="list1" type="string">
	<cfargument name="list2" type="string">
	<cfargument name="appendFlag" type="string" required="false" default="+">
	<cfargument name="deleteFlag" type="string" required="false" default="-">
	<cfargument name="delimiters" type="string" required="false" default=",">
	
	<cfset var i = "">
	
	<cfloop list="#arguments.list2#" index="i" delimiters="#arguments.delimiters#">
	
		<cfif Left(i,1) EQ arguments.appendFlag>
			<cfset i = ReplaceNoCase(i,arguments.appendFlag,"")>
			<cfset arguments.list1 = ListAppend(arguments.list1,i,arguments.delimiters)>
		<cfelseif Left(i,1) EQ arguments.deleteFlag>
			<cfset i = ReplaceNoCase(i,arguments.deleteFlag,"")>
			<cfset arguments.list1 = this.fnListDelete(arguments.list1,i)>
		</cfif>
	
	</cfloop>
	
	<cfreturn arguments.list1>
	
</cffunction>

<cffunction name="fnListNextVal" output="false" returntype="string" hint="Get next value from a list given a current value. NB returns blank string if there are no more records (can return first value with wrap = 1)">
	
	<cfargument name="list" type="string" required="true">
	<cfargument name="val" type="string" required="true">
	<cfargument name="wrap" type="boolean" required="false" default="0" hint="Return first ID instead of blank if no more records">
	
	<cfset var sLocal = StructNew()>
	<cfset  local.res = "">

	<cfset local.pos = ListFind(arguments.list,arguments.val)>

	<cfif local.pos>
		
		<cfif local.pos eq ListLen(arguments.list)>
			<cfif arguments.wrap>
				<cfset local.nextpos = 1>
			<cfelse>
				<cfset local.nextpos = 0>
			</cfif>
		<cfelse>
			<cfset local.nextpos = local.pos + 1>
		</cfif>
	<cfelse>
		<cfset local.nextpos = 0>
	</cfif>

	<cfif local.nextpos>
		<cfset local.res = ListGetAt(arguments.list,local.nextpos)>
	</cfif>

	<cfreturn local.res>

</cffunction>

<cffunction name="fnListPrevVal" output="false" returntype="string" hint="Get previous value from a list given a current value. NB returns blank string if there are no more records (can return first value with wrap = 1)">
	
	<cfargument name="list" type="string" required="true">
	<cfargument name="val" type="string" required="true">
	<cfargument name="wrap" type="boolean" required="false" default="0" hint="Return first ID instead of blank if no more records">
	
	<cfset var sLocal = StructNew()>
	<cfset  local.res = "">

	<cfset local.pos = ListFind(arguments.list,arguments.val)>

	<cfif local.pos>
		
		<cfif local.pos eq 1>
			<cfif arguments.wrap>
				<cfset local.nextpos = ListLen(arguments.list)>
			<cfelse>
				<cfset local.nextpos = 0>
			</cfif>
		<cfelse>
			<cfset local.nextpos = local.pos - 1>
		</cfif>
	<cfelse>
		<cfset local.nextpos = 0>
	</cfif>

	<cfif local.nextpos>
		<cfset local.res = ListGetAt(arguments.list,local.nextpos)>
	</cfif>

	<cfreturn local.res>

</cffunction>

<cffunction name="fnQueryNextKey" output="true" returntype="string" hint="Given a query, a fieldname and a field value, determines the value of the field in the next row
 after the row in which the current value matches. Obviously the field is intended to be the primary key but it will work on any unique, not null
 and non blank column. NB returns blank string if there are no more records (can return first value with wrap = 1)">
	
	<cfargument name="sQuery" type="query" required="true">
	<cfargument name="fieldname" type="string" required="true">
	<cfargument name="fieldValue" type="string" required="true">
	<cfargument name="wrap" type="boolean" required="false" default="0" hint="Return first ID instead of blank if no more records">
	
	<cfset var sLocal = StructNew()>
	
	<cfset sLocal.rowNum = 0>
	
	<cfloop query="arguments.sQuery">
		<cfif 	arguments.sQuery[arguments.fieldname][currentrow] eq arguments.fieldValue>
			<cfset sLocal.rowNum = currentRow>
			<cfbreak>
		</cfif>
	</cfloop>
		
	<cfif NOT sLocal.rowNum>
		<cfthrow message="Field value #arguments.fieldValue# not found for field #arguments.fieldname# in query ">
	</cfif>
	
	<cfif sLocal.rowNum eq arguments.sQuery.recordcount>
		<cfif arguments.wrap>
			<cfset sLocal.nextRow = 1>
		<cfelse>
			<cfset sLocal.nextRow = 0>
		</cfif>
	<cfelse>
		<cfset sLocal.nextRow = sLocal.rowNum + 1>
	</cfif>
	
	<cfif sLocal.nextRow>
		<cfset sLocal.nextVal = arguments.sQuery[arguments.fieldname][sLocal.nextRow]>
	<cfelse>
		<cfset sLocal.nextVal = "">
	</cfif>
	
	
	<cfreturn sLocal.nextVal>
	
</cffunction>

<cffunction name="fnQueryPreviousKey" output="true" returntype="string" hint="Given a query, a fieldname and a field value, determines the value of the field in the next row
 before the row in which the current value matches. Obviously the field is intended to be the primary key but it will work on any unique, not null
 and non blank column. NB returns blank string if there are no more records (can return last value with wrap = 1)">
	
	<cfargument name="sQuery" type="query" required="true">
	<cfargument name="fieldname" type="string" required="true">
	<cfargument name="fieldValue" type="string" required="true">
	<cfargument name="wrap" type="boolean" required="false" default="0" hint="Return first ID instead of blank if no more records">
	
	<cfset var sLocal = StructNew()>
	
	<cfset sLocal.rowNum = 0>
	
	<cfloop query="arguments.sQuery">
		<cfif 	arguments.sQuery[arguments.fieldname][currentrow] eq arguments.fieldValue>
			<cfset sLocal.rowNum = currentRow>
			<cfbreak>
		</cfif>
	</cfloop>
		
	<cfif NOT sLocal.rowNum>
		<cfthrow message="Field value #arguments.fieldValue# not found for field #arguments.fieldname# in query ">
	</cfif>
	
	<cfif sLocal.rowNum eq 1>
		<cfif arguments.wrap>
			<cfset sLocal.nextRow = arguments.sQuery.recordcount>
		<cfelse>
			<cfset sLocal.nextRow = 0>
		</cfif>
	<cfelse>
		<cfset sLocal.nextRow = sLocal.rowNum - 1>
	</cfif>
	
	<cfif sLocal.nextRow>
		<cfset sLocal.nextVal = arguments.sQuery[arguments.fieldname][sLocal.nextRow]>
	<cfelse>
		<cfset sLocal.nextVal = "">
	</cfif>
	
	
	<cfreturn sLocal.nextVal>
	
</cffunction>

<cffunction name="fnLoadSettingsFromFile" output="No" returntype="struct" hint="Load a tab or : separated settings file into a struct"
			notes="Parse a settings file in format setting(.property)[:|tab]value format.<br><br>
			Comments can be /* */ blocks, or on any line with a double
				forward slash (//)<br><br>Settings will be returned as simple values unless they have
				properties (after a .) in which case they will be structs.">
	
	<cfargument name="filename" required="Yes" type="string" hint="Path/url/mapping to file to load settings from.">
	
	<cfscript>
	var sLocal = StructNew();
	sLocal.settingsValues = StructNew();
	sLocal.textdata = fnReadFile(arguments.fileName);
	//remove comment blocks /* */
	sLocal.textdata = ReReplaceNoCase(sLocal.textdata,"\/\*.*?\*\/","","all");
	//split into an array for listing
	sLocal.textArray = ListToArray(sLocal.textdata,"#chr(13)##chr(10)#");
	</cfscript>
	
	<cfloop array="#sLocal.textArray#" index="sLocal.i">
		<cfscript>
		sLocal.settingStr = sLocal.i;
		// ignore trailing comments (//)
		sLocal.commentPos =  Find("//", sLocal.i);
		if (sLocal.commentPos gt 1) {
			sLocal.settingStr = Left(sLocal.settingStr,sLocal.commentPos - 1);
		}
		else if (sLocal.commentPos) {
			sLocal.settingStr = "";
		}
		
		if (ListLen(sLocal.settingStr, " 	:") gt 1) {
			sLocal.code = Trim(ListFirst(sLocal.settingStr, " 	:"));
			sLocal.value = Trim(ListRest(sLocal.settingStr, " 	:"));
			// Create sub structs for properties
			if (ListLen(sLocal.code,".") gt 1) {
				sLocal.subCode = ListLast(sLocal.code,".");
				sLocal.code = ListFirst(sLocal.code,".");
				if (NOT StructKeyExists(sLocal.settingsValues,sLocal.code)) {
					sLocal.settingsValues[sLocal.code] = StructNew();
				}
				sLocal.settingsValues[sLocal.code][sLocal.subCode] = sLocal.value;
			}
			else {
				sLocal.settingsValues[sLocal.code] = sLocal.value;
			}
		}
		</cfscript>
	</cfloop>
	
	<cfreturn sLocal.settingsValues>
	
</cffunction>

<cffunction name="fnDbTableInfo" output="false" returntype="struct" hint="Returns a struct of database table information given a table and datasource name.">
	
	<cfargument name="table_name" required="true" type="string" hint="The name of the table to get the info from.">
	<cfargument name="dsn" required="true" type="string" hint="The name of the datasource to use.">
	
	<cfset var local = {}>
	
	<cfquery datasource="#arguments.dsn#" name="local.qTable">
	SELECT 
	   ORDINAL_POSITION
	  ,COLUMN_NAME
	  ,DATA_TYPE
	  ,CHARACTER_MAXIMUM_LENGTH
	  ,IS_NULLABLE
	  ,COLUMN_DEFAULT
	FROM   
	  INFORMATION_SCHEMA.COLUMNS 
	WHERE   
	  TABLE_NAME = '#arguments.table_name#'
	ORDER BY 
	  ORDINAL_POSITION ASC;
	</cfquery>
	
	<cfreturn QueryToStructOfStructures(local.qTable,"COLUMN_NAME")>
	
</cffunction>

<cffunction name="fnSqlServerTypeToColdfusionSqlType" output="false" returntype="string" hint="Returns a string for a Coldfusion datatype given an SQL server data type. Defaults to VARCHAR.">
	
	<cfargument name="DATA_TYPE">
	
	<cfswitch expression="#arguments.DATA_TYPE#">
		<cfcase value="int">
			<cfreturn "cf_sql_integer">
		</cfcase>
		<cfcase value="bit">
			<cfreturn "cf_sql_bit">
		</cfcase>
		<cfdefaultcase>
			<cfreturn "cf_sql_varchar">
		</cfdefaultcase>
	</cfswitch>
	
</cffunction>

<cffunction name="fnGetMIMETypeFromExtension" output="false"  returntype="string" hint="Return mime type for given extension. Uses data configured in mimeTypes.txt">

	<cfargument name="extension" required="yes">
		
	<cfset var mimeType = "">

	<!--- remove . from front of extensions --->
	<cfset arguments.extension = ListLast(arguments.extension,".")>	
		
    <cfif NOT ISDefined("this.mimeMappings")>
		<cfif NOT (IsDefined("variables.mappings") AND StructKeyExists(variables.mappings,"utils"))>
			<cfthrow message = "Object must be initialised with a mapping for 'utils' to use this function">
		</cfif>
		
		<cfset this.mimeMappings = fnLoadSettingsFromFile("utils/mimeTypes.txt")>
		
	</cfif>
			
	<cfif StructKeyExists(this.mimeMappings,arguments.extension)>
		<cfset mimeType = this.mimeMappings[arguments.extension]>
	</cfif>

	<cfreturn mimeType>
	
</cffunction>

<cffunction name="fnGetLogSettings" output="false" returntype="Struct">
	<cfset var logSettings = {}>
	<cfset var s = ''>

	<cfloop list="log,logCategories,log_mode,logLineInfo,log_dsn" index="s">
		<cfif structKeyExists(variables, s)>
			<cfset logSettings[s] = variables[s]>
		</cfif>
	</cfloop>
	<cfreturn logSettings>
</cffunction>

<cffunction name="fnLog" output="yes" returntype="void" hint="Write to log (if this.log is true) or just trace if in debug mode."> 

	<cfargument name="text" required="Yes" hint="Text to log">
	<cfargument name="type" required="No" default="Information" hint="The type of logging">
	<cfargument name="category" required="No" default="" hint="List of categories to log. See fnAddLogCategory. Blank will log if all is on.">
	
	<cfset var context = []>
	
	<!--- log all errors and warnings --->
	<cfswitch expression="#arguments.type#">
		<cfcase value="warning,w,error,e">
			<cfset local.log = 1>
		</cfcase>
		<cfdefaultcase>
			<cfset local.log = 0>
		</cfdefaultcase>
	</cfswitch>

	<!--- are we loggin all categories? --->
	<cfset local.log = local.log OR (variables.log AND StructKeyExists(variables.logCategories,"all"))>

	<cfif NOT local.log>
		<cfif variables.log>
			<cfloop index="local.cat" list="#arguments.category#">
				<cfif structKeyExists(variables.logCategories, local.cat)>
					<cfset local.category = local.cat>
					<cfset local.log = 1>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
	<cfelse>
		<cfset local.category = ListFirst(arguments.category)>
	</cfif>

	<cfif local.log>
		<!--- If in debug mode, get a stack trace so we can add file/line information to the logging --->
		<cfif IsDebugMode() AND variables.logLineInfo>
			<cftry>
				<cfthrow message="Get stack trace">
				<cfcatch>
					<cfset context = cfcatch.tagcontext>
				</cfcatch>
			</cftry>
			
			<cfif arrayLen(context) gt 1>
				<cfset arguments.text &= "(#context[2].template#:#context[2].line#)">
			</cfif>
		</cfif>
		
		<cfif variables.log_mode eq "db">

			<!--- request_id allows all log entries from the same request to be viewed --->
			<cfparam name="request.logrunID" default="#createUUID()#">

			<cfif arguments.category eq "">
				<cfset local.categoryNULL = 1>
			<cfelse>
				<cfset local.categoryNULL = 0>
			</cfif>
			<cfquery datasource="#variables.log_dsn#" name="local.insertLog">
			INSERT INTO [cflog]
           ([logtype]
           ,[cflog_category]
           ,[log_text]
           ,[server_name]
           ,request_id)
     		VALUES
           (<cfqueryparam cfsqltype="cf_sql_char" value="#UCASE(Left(arguments.type,1))#">
           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.category#" null="#local.categoryNULL#">
           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(arguments.text,8000)#">
           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.server_name#">
           ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.logrunID#">)
           </cfquery>

		<cfelseif isDebugMode() AND (NOT IsDefined("_cf_nodebug") OR NOT (_cf_nodebug))>
			<cftrace text="#arguments.text#">
		<cfelseif variables.log>
			<cflog file="#application.ApplicationName#_debug" type="#arguments.type#" text="#arguments.text#">
		</cfif>
	</cfif>
    
</cffunction>

<cffunction name="fnSetLog" output="No" returntype="void" hint="Set the boolean variable to turn file logging on or off. Use fnAddLogCategory() be preference"> 

	<cfargument name="log" required="no" type="boolean" default="true" hint="Boolean to turn logging on or off.">
	<cfargument name="categories" required="no" default="all"  hint="Categories to filter on (supply a list of catgeories here and a category param to fnLog to
	filter log requests">
	<cfargument name="lineInfo" required="no" default="false" hint="Turn on addition of lineInfo (calling file and line number) to traces">
	<cfargument name="mode" required="no" default="text" hint="text|db">
	<cfargument name="dsn" required="no" default="" hint="Required if mode = db">
	
	
	<cfset variables.log = arguments.log>
	<cfset variables.logCategories = {}>

	<cfif variables.log>
		<cfloop index="local.cat" list="#arguments.categories#">
			<cfset variables.logCategories[local.cat] = 1>
		</cfloop>
	</cfif>

	<cfset variables.logLineInfo = arguments.lineInfo>
	
	<cfif variables.log AND arguments.mode eq "db" AND arguments.dsn eq "">
		<cfthrow message="No dsn defined for log mode">
	</cfif>

	<cfset variables.log_mode = arguments.mode>
	<cfset variables.dsn = arguments.dsn>

</cffunction>

<cffunction name="fnSetDBLogMode" output="no" returntype="void" hint="Turn on logging to database. Requires DSN - and sql log tables (see create_log_tables.sql)"> 

	<cfargument name="DBLogMode" required="no" type="boolean" default="true" hint="Boolean to turn DB logging on or off.">
	<cfargument name="dsn" required="no" hint="required if turning on" >

	<cfif arguments.DBLogMode>
		<cfif NOT IsDefined("arguments.dsn") OR arguments.dsn eq "">
			<cfthrow message="DSN required if turning on DB log mode">
		</cfif>
		<cfset variables.log_dsn = arguments.dsn>
		<cfset variables.log_mode = "db">
		<cfset variables.log = 1>
	<cfelse>
		<cfset variables.log_mode = "text">
	</cfif>
		
</cffunction>

<cffunction name="fnAddLogCategory" output="No" returntype="void" hint="Add a category to logging. If logging is off, we turn it on. If category is all, leave this."> 

	<cfargument name="category" required="yes" hint="Categories to add">
	
	<cfloop index="local.cat" list="#arguments.category#">
		<cfif len(local.cat) gt 20>
			<cfthrow message="Category must be 20 chars or less">
		</cfif>
		<cfset variables.logCategories[local.cat] = 1>
	</cfloop>
	
	<cfset variables.log = 1>
		
</cffunction>

<cffunction name="fnRemoveLogCategory" output="No" returntype="boolean" hint="Remove a category from logging. If last category, turn logging off. Returns false if not found"> 

	<cfargument name="category" required="yes" hint="Categories to add">
	
	<cfset local.loggingFound = 0>

	<cfloop index="local.cat" list="#arguments.category#">
		<cfset local.loggingFound = local.loggingFound OR StructDelete(variables.logCategories,local.cat)>
	</cfloop>

	<cfif NOT StructCount(variables.logCategories)>
		<cfset variables.log = 0>
	</cfif>


	<cfreturn local.loggingFound>
		
</cffunction>

<cffunction name="fnViewLog" output="true" hint="Output log entries for current request"> 

	<cfargument name="category" default="">
	<cfargument name="server" required="false">
	
	<cfif NOT StructKeyExists(request,"logrunID") AND NOT structKeyExists(arguments, "server")>
		<p>No log entries for this request</p>
	<cfelse>	
	
		<cfquery datasource="#variables.log_dsn#" name="local.qLog">
		SELECT [logtime]
	          ,[logtype]
	          ,[cflog_category]
	          ,[log_text]
	          ,[server_name]
     	FROM     cflog WITH (NOLOCK)
     	<cfif structKeyExists(arguments, "server")>
     	WHERE	server_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.server#">
     	<cfelse>
     	WHERE    request_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.logrunID#">
     	</cfif>
     	<cfif arguments.category neq "">
     	AND     cflog_category IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#" list="yes">)
     	</cfif>
     	ORDER by logtime_exact
        </cfquery>

		<table class="info" border="1" cellpadding="2" cellspacing="0" style="background-color: white; color: black;">
			<tr>
				<th>Time</th>
				<th>Type</th>
				<th>Cat</th>
				<th>Text</th>
			</tr>
		<cfloop query="local.qLog">
			<tr>
				<td>#logtime#</td>
				<td>#logtype#</td>
				<td>#cflog_category#</td>
				<td style="padding-left:5px; text-align:left;">#log_text#</td>
			</tr>
		</cfloop>
		</table>
    </cfif>

</cffunction>

<cffunction name="fnWritePackageCompressionFile" output="false" returntype="void" hint="write a file to compress packages on servers">
	<cfargument name="batchFile" type="string" required="true" hint="Path to the batch file.">
	<cfargument name="servers_roles_ids" type="string" default="1,2,3,4" required="false" hint="Servers roles to include in this script">

	<cfset var local = {}>

	<cfset local.serversList = ''>

	<cfquery datasource="#application.settings.dsn#" name="local.qServers">
	SELECT		s.servers_id, s.name
	FROM		servers s WITH (NOLOCK)
	INNER JOIN 	servers_servers_roles_join SSJ
	ON			S.servers_id = SSJ.servers_id
	WHERE		SSJ.servers_roles_id in (<cfqueryparam value="#arguments.servers_roles_ids#" list="true" cfsqltype="cf_sql_integer">)
	GROUP BY 	s.servers_id, s.name
	ORDER BY	s.name
	</cfquery>

	<cfloop query="local.qServers">
		<cfset local.serversList = listAppend(local.serversList, '"#ListFirst(name,'.')#"', ',')>
	</cfloop>
<cfsavecontent variable="local.fileContent">
' This script will compress JS and CSS packages on all production servers.
' It is intended to be run after servers_copy.
' USAGE:
'  	simply provide a list of servers below. Then run from the comman line using `cscript compressPackages.vbs`

' Provide list of servers to compress scripts on. This should be the server prefixes only!
servers = Array (<cfoutput>#local.serversList#</cfoutput>)
' servers = Array ("tpc22")

' Unfortunately VB doesn't know try-catch, so have to employ some other magic to cope with unavailable servers ...
On Error Resume Next
Err.Clear ' make sure we are starting with an empty slate
' initialize some counters
errors = 0
total = 0
' We will set this to true if we need compression
needJsComp = false
needCssComp = false

Wscript.Echo "+-----------------------------------+"
Wscript.Echo "| COMPRESS PACKAGES FILES IF NEEDED |"
Wscript.Echo "+-----------------------------------+"
Wscript.Echo ""

' Check _common/_scripts and _common/_styles folder (and sub folder) for files: We only want to selectively compress as needed

Set objFSO = CreateObject("Scripting.FileSystemObject")

Wscript.Echo "Checking _scripts folder"
Call CheckFolder(".\wwwroot\_common\_scripts")

Wscript.Echo "Checking _styles folder"
Call CheckFolder(".\wwwroot\_common\_styles")

Wscript.Echo ""
Wscript.Echo "Need JS compression:  " & needJsComp 
Wscript.Echo "Need Css compression: " & needCSSComp

If needJsComp OR needCssComp Then

	' Loop over the servers
	for each s in servers
		total = total+1
		
		'set URL (append a randum number to avoid caching)
		reloadURL = "https://"& s &".clikpic.com/manage/reload.cfm?cache="&Rnd

		' now append arguments to compress as needed
		If needJsComp Then
			reloadURL = reloadURL & "&compressScripts=1"
		End If

		If needCssComp Then
			reloadUrl = reloadUrl & "&compressCss=1"
		End If

		WScript.Echo ""
		WScript.Echo "Compressing Packages on " & s
		' WScript.Echo "URL: " & reloadURL

		' Download the specified URL
		Set objHTTP = CreateObject( "WinHttp.WinHttpRequest.5.1" )
		objHTTP.Open "GET", reloadURL, False
		objHTTP.Send

		' check if request was successfull, otherwise show error
		If Err.Number <> 0 Then
		    WScript.Echo "   Error: " &  Err.Description
			Err.Clear ' clear errors
			errors = errors + 1
		Else
			' Output what happened
			' WScript.Echo objHTTP.ResponseText
			If objHTTP.Status = 200 Then
			  WScript.Echo "    OK    (" & objHTTP.Status & ")"
			Else
			  WScript.Echo "    ERROR (" & objHTTP.Status & ": '"& objHTTP.StatusText &"')"
			  errors = errors + 1
			End If
		End If
	next

	WScript.Echo ""
	WScript.Echo "Done compressing Packages on "&total&" server(s) with "&errors&" errors"
End If


' Check a folder for existence, and then check if it or its sub folders contain any JS or CSS files
Sub CheckFolder(path)
	If objFSO.FolderExists(path) Then
		Set objSuperFolder = objFSO.GetFolder(path)
		Call checkSubForFiles (objSuperFolder)
	Else
		Wscript.Echo " ! Folder '"&path&"' doesn't exist"
	End If
End Sub

' Loop recursively through a folder to see if it contains CSS or JS files
Sub checkSubForFiles(fFolder)
    Set objFolder = objFSO.GetFolder(fFolder.Path)
    Set colFiles = objFolder.Files
    For Each objFile in colFiles
        If UCase(objFSO.GetExtensionName(objFile.name)) = "JS" Then
            needJsComp = true
        ElseIf UCase(objFSO.GetExtensionName(objFile.name)) = "CSS" Then
            needCssComp = true
        End If
    Next

    For Each Subfolder in fFolder.SubFolders
        checkSubForFiles(Subfolder)
    Next
End Sub
</cfsavecontent>
<cffile action="WRITE" file="#arguments.batchFile#" output="#local.fileContent#">

</cffunction>


<cffunction name="fnWriteDistributionBatchFile" output="false" returntype="void" hint="Write a batch file to distribute content between servers in the workgroup.">
	
	<cfargument name="servers" type="struct" required="true" hint="Struct of server details e.g. from Clikpic object.">
	<cfargument name="serverSettings" type="struct" required="true" hint="Struct of settings for different servers e.g. from clikpic.ini">
	<cfargument name="batchFile" type="string" required="true" hint="Path to the batch file.">
	<cfargument name="pathMapping" type="struct" required="false" hint="Struct mapping directories in the distribution root to paths on the servers.">
	<cfargument name="addPrompt" type="boolean" required="false" default="false" hint="Write a prompt into the file?">
	<cfargument name="packageCompressionScript" type="string" required="false" hint="file name of package compression script to call">
	<cfset var local = {}>
	
	<!--- Start the file. --->
	<cfoutput>
		<cfsavecontent variable="local.fileContent">
REM	#DateFormat(now(),"medium")#
REM Copy files from the directory structure to all other servers
		</cfsavecontent>
	</cfoutput>
	
	<cffile action="WRITE" file="#arguments.batchFile#" output="#local.fileContent#">
	
	<!--- Add a prompt to the start of the script. --->
	<cfsavecontent variable="local.fileContent">
		<cfif arguments.addPrompt>
SET /P ANSWER=Continue with distribution (Y/N)?
if /i {%ANSWER%}=={y} (goto :yes)
if /i {%ANSWER%}=={yes} (goto :yes)
goto :no
:yes
		</cfif>
echo Starting distribution...
	</cfsavecontent>
	
	<cffile action="APPEND" file="#arguments.batchFile#" output="#local.fileContent#">
	
	<cfset local.thisServerSettings = arguments.serverSettings[server.server_name]>
	
	<!--- Loop over the list of servers loaded into the object. --->
	<cfloop collection="#arguments.servers#" item="local.servers_id">
	
		<!--- Set a struct of settings for the server, either from the Clikpic object or create a blank one. --->
		<cfif StructKeyExists(arguments.serverSettings,arguments.servers[local.servers_id].name)>
			
			<cfset local.tmpSettings = arguments.serverSettings[arguments.servers[local.servers_id].name]>
			
			<!--- Combine the settings for the server with the common ones. --->
			<cfset local.success = StructAppend(tmpSettings,arguments.serverSettings.common)>
			
			<!--- Set a variable for the netbios name - just convenience. --->
			<cfset local.netbios_name = arguments.servers[local.servers_id].netbios_name>
			
			<!--- If there's a netbios name then we can copy files over to it. --->
			<cfif local.netbios_name NEQ "">
				<cfoutput>
					<!--- Add in xcopy directives for the webroot, the customtags and the settings for each server. --->
					<cfsavecontent variable="local.fileContent">
						<cfif StructKeyExists(arguments,"pathMapping")>
							<cfloop collection="#arguments.pathMapping#" item="local.dataRoot">
								<cfif StructKeyExists(local.tmpSettings,arguments.pathMapping[local.dataRoot])>
									<cfset local.location = local.tmpSettings[arguments.pathMapping[local.dataRoot]]>
								<cfelse>
									<cfset local.location = arguments.pathMapping[local.dataRoot]>
								</cfif>
								<cfif arguments.servers[local.servers_id].name EQ server.server_name>
xcopy #local.thisServerSettings.dataroot#\#local.dataRoot#\*.*  #local.location# /E /I /R /Y								
								<cfelse>
xcopy #local.thisServerSettings.dataroot#\#local.dataRoot#\*.*  \\#local.netbios_name#\#ReplaceNoCase(local.location,":","$")# /E /I /R /Y
								</cfif>
								
							</cfloop>
							
						<cfelse>
							<cfif arguments.servers[local.servers_id].name EQ server.server_name>
xcopy #local.thisServerSettings.dataroot#\wwwroot\*.*  #local.thisServerSettings.siteroot# /E /I /R /Y
xcopy #local.thisServerSettings.dataroot#\customtags\*.*  #local.thisServerSettings.customtags# /E /I /R /Y
xcopy #local.thisServerSettings.dataroot#\settings\*.*  #local.thisServerSettings.settings# /E /I /R /Y
							<cfelse>
xcopy #local.thisServerSettings.dataroot#\wwwroot\*.*  \\#local.netbios_name#\#ReplaceNoCase(local.tmpSettings.siteroot,":","$")# /E /I /R /Y
xcopy #local.thisServerSettings.dataroot#\customtags\*.*  \\#local.netbios_name#\#ReplaceNoCase(local.tmpSettings.customtags,":","$")# /E /I /R /Y
xcopy #local.thisServerSettings.dataroot#\customtags\*.*  \\#local.netbios_name#\#ReplaceNoCase(local.tmpSettings.settings,":","$")# /E /I /R /Y
							</cfif>
						</cfif>						
					</cfsavecontent>
				</cfoutput>
				
				<!--- Append the script to the batch file. --->
				<cffile action="APPEND" file="#arguments.batchFile#" output="#local.fileContent#">
			</cfif>
		
		<cfelse>
			<cfset this.fnLog("No settings found for #local.servers_id#: #arguments.servers[local.servers_id].name#")>
		</cfif>
		
	</cfloop>
	
	<!--- append call for compression script --->
	<cfif structKeyExists(arguments, "packageCompressionScript") AND arguments.packageCompressionScript neq ''>
		<cffile action="APPEND" file="#arguments.batchFile#" output="#chr(10)##chr(13)#cscript #arguments.packageCompressionScript#">
	</cfif>
	
	<cfif arguments.addPrompt>
		<!--- Add the end of the prompt logic to the end of the file. --->
		<cfsavecontent variable="local.fileContent">
exit /b 0

:no
echo Distribution cancelled.
exit /b 1
		</cfsavecontent>
		
		<cffile action="APPEND" file="#arguments.batchFile#" output="#local.fileContent#">
	</cfif>
		
</cffunction>

<cffunction name="fnHTMLAttrFormat" output="No" returntype="string" hint="Format a string to be displayed in a tag attribute - escape quotes, strip out html tags etc">
	
	<cfargument name="string" type="string" required="true" hint="The string to format">
	<cfset var local = {}>
	
	<cfif find("<",arguments.string)>
		<cfset arguments.string = rereplace(arguments.string, "<[^>]+>", "", "all")>
	</cfif>
	
	<cfset local.out = HTMLEditFormat(arguments.string)>
	
	<cfreturn local.out>

</cffunction>

<cffunction name="fnUploadFile" output="No" returntype="struct" hint="Upload a file">
	
	<cfargument name="formFile" type="string" required="true" hint="Field of upload">
	<cfargument name="directory" type="string" required="true" hint="Directory to upload to">
	<cfargument name="accept" type="string" required="no" default="jpg,gif,png,pdf" hint="EXTENSIONS of mime types to accept (see fnGetMIMETypeFromExtension)">
	<cfargument name="nameConflict" type="string" required="no" default="MakeUnique" hint="Action to take on name conflict Error|Skip|overwrite|makeUnique">
	
	<cfset var local = {}>
	<cfset local.file = {}>
		
	<cfset local.MimeTypes = "">
	<cfloop index="local.ext" list="#arguments.accept#">
		<cfset local.MimeTypes = ListAppend(local.MimeTypes,fnGetMIMETypeFromExtension(local.ext))>
	</cfloop>
		
	<cftry>
		<cffile action="upload" fileField="#arguments.formField#"
								destination="#arguments.directory#"
								accept="#local.MimeTypes#"
								nameConflict="#arguments.nameConflict#"
								result="local.file">
		
		<cfcatch>
			<cfset local.file.fileWasSaved = 0>
			<cfset local.file.error = Duplicate(cfcatch)>	
		</cfcatch>
	</cftry>
	
	<cfreturn local.file>
	
</cffunction>

<cffunction name="fnRenameFile" output="No" returntype="struct" hint="Rename a file.">
	
	<cfargument name="source" type="string" required="true" hint="File to rename">
	<cfargument name="destination" type="string" required="true" hint="Destination file or directory.">
			
	<cfset var local = {}>
	<cfset local.file = {}>
		
	<cfif NOT FileExists(arguments.source)>
		<cfset local.file.fileWasSaved = 0>
		<cfset local.file.error.message = "File #arguments.source# not found">
	<cfelse>
		
		<cftry>
			<cffile action="rename" source="#arguments.source#"
									destination="#arguments.destination#">
			
			<cfcatch>
				<cfset local.file.fileWasSaved = 0>
				<cfset local.file.error = Duplicate(cfcatch)>	
			</cfcatch>
		</cftry>
	</cfif>
	
	<cfreturn local.file>
	
</cffunction>

<cffunction name="alphanumeric" output="No" returntype="string" hint="Replace non alphanumeric chars in a filename">
	<cfargument name="filename" type="string" required="true" hint="Filename to check">
	
	<cfset local.tempName = ListFirst(arguments.filename,".")>
	<cfset local.tempExt = ListLast(arguments.filename,".")>
	<cfset local.tempName = Replace(local.tempName," ","_","all")>
	<cfset local.checkName = REReplace(local.tempName,"[^\w_\-\.]","","all") & "." & local.tempExt>
	
	<cfreturn local.checkName>

</cffunction> 

<cffunction name="fnWebsafeFileName" output="No" returntype="struct" hint="Make filename websafe. Will append numeric value if the resultant string is not unique.">
	
	<cfargument name="source" type="string" required="true" hint="File to check and rename if required.">
			
	<cfset var i = false>
	<cfset local.file = {}>
	
	<cfset local.file.fileOk = 1>
	<cfset local.file.fileExisted = 0>
	<cfset local.file.fileWasRenamed = 0>
		
	<cfif NOT FileExists(arguments.source)>
		<cfset local.file.fileOk = 0>	
		<cfset local.file.error.message = "File #arguments.source# not found">
	<cfelse>
		
		<cfset local.sourceFile = ListLast(arguments.source,"\/")>
		<cfset local.checkName = alphanumeric(local.sourceFile)>
		
		<cfset this.fnLog(text="fnWebsafeFileName= checkName is #local.checkName#")>
		
		<cfif (local.sourceFile neq local.checkName)>
			
			<cfset local.destinationDir = GetDirectoryFromPath(arguments.source)>
				
			<cfif FileExists("#local.destinationDir#\#local.checkName#")>
				<cfset local.file.fileExisted = 1>
				<cfloop index="i" from="1" to="10000">
					<cfset local.checkName2 = Replace(local.checkName,".","#i#.")>
					<cfif NOT FileExists("#local.destinationDir#\#local.checkName2#")>
						<cfset local.checkName = local.checkName2>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
					
			<cftry>
				<cffile action="rename" source="#arguments.source#"
									destination="#local.checkName#">
				<cfset local.file.fileWasRenamed = 1>
				<cfcatch>
					<cfset local.file.fileOk = 0>
					<cfset local.file.error = Duplicate(cfcatch)>	
				</cfcatch>
			</cftry>		
					
			
		</cfif>
		
		<cfif local.file.fileOk>
			<cfset local.file.serverFile = local.checkName>
		</cfif>				
	</cfif>
	
	<cfreturn local.file>
	
</cffunction>	
	
<cffunction name="fnDeleteFile" output="No" returntype="struct" hint="Delete a file">
	
	<cfargument name="fileName" type="string" required="true" hint="File to delete">
	
	<cfset var local = {}>
	<cfset local.file = {}>
		
	<cfif NOT FileExists(arguments.fileName)>
		<cfset local.file.fileWasDeleted = 0>
		<cfset local.file.error.message = "File #arguments.source# not found">
	<cfelse>
		<cftry>
			<cffile action="delete" file="#arguments.fileName#">
			
			<cfcatch>
				<cfset local.file.fileWasDeleted = 0>
				<cfset local.file.error = Duplicate(cfcatch)>	
			</cfcatch>
		</cftry>
	</cfif>
	
	<cfreturn local.file>
	
</cffunction>
	
<cffunction name="fnFileSize" hint="Return the size of a file in bytes." returntype="string">
	
	<cfargument required="yes" name="filepath">
	
	<cfset var tempDir = "">
	
	<cfif NOT FileExists(arguments.filepath)>
		<cfset this.fnLog(type="Warning", text="File not found for function FileSize")>
		<cfreturn 0>
	</cfif>
	
	<cfdirectory directory="#GetDirectoryFromPath(arguments.filepath)#" name="tempDir" filter="#GetFileFromPath(arguments.filepath)#">
	
	<cfif NOT tempDir.recordcount>
		<cfset this.fnLog(type="Warning", text="Unable to list directory for fnFileSize")>
		<cfreturn 0>
	</cfif>
	
	<cfset this.fnLog(type="Information", text="FileSize is #FileSizeFormat(tempDir.size)#")>
	<cfreturn tempDir.size>
	
</cffunction>

<cffunction name="pad" hint="Pad a string to a given length">
	<cfargument required="yes" name="str">
	<cfargument required="yes" name="length">
	<cfargument required="no" name="trim" type="boolean" default="1" hint="trim if too long">
	
	<cfscript>
	var retval = arguments.str;
	if (len(arguments.str) lt arguments.length) {
	 retval &= RepeatString(" ",arguments.length-Len(arguments.str));
	}
	else if (len(arguments.str) gt arguments.length AND arguments.trim) {
		retval = left(retval,arguments.length);
	}	
	return retVal;
	</cfscript>
</cffunction>

<cffunction name="fnParseTagAttributes" output="No" returntype="Struct" hint="Parse attributes into a struct from a single tag string (e.g. [image id=xx]). Tag can be < or << or [ or [[ enclosed. Attributes can be single quoted, double quote or alpha numeric">
		
	<cfargument name="text" type="string" required="Yes" hint="The full tag string (start tag only, tag name ignored).">
		
	<cfscript>
	var temp = StructNew();
	var stext = ReplaceList(arguments.text,"����","',',','");
	var stext = ListFirst(Trim(stext),"[]<>");
	var attrVals = ListRest(sText," ");

	if (NOT IsDefined("variables.attrPattern")) {
		local.patternObj = createObject( "java", "java.util.regex.Pattern");
		local.myPattern = "(\w+)(\s*=\s*(""(.*?)""|'(.*?)'|([^'"">\s]+)))";
		variables.attrPattern = local.patternObj.compile(local.myPattern);
	}

	local.tagObjs = variables.attrPattern.matcher(attrVals);

	while (local.tagObjs.find()){
	    temp[tagObjs.group(javacast("int",1))] = reReplace(tagObjs.group(javacast("int",3)), "^(""|')(.*?)(""|')$", "\2");
	}

	return temp;
	</cfscript>

</cffunction>

<cffunction name="fnParseTagValues" output="No" returntype="string" hint="Parse value of a tag">
	
	<cfargument name="text" type="string" required="Yes" hint="The text to search">
	<cfargument name="tagName" type="string" required="No">
	
	<cfscript>
	var retVal = "";
	var SearchVals = false;
	arguments.text = Trim(arguments.text);
	
	// if (left(arguments.text,1) neq "[") {
	// 	writeDump(arguments.text);
	// 	writeOutput("not ok");
	// 	abort;
	// }
	// else {
	// 	writeOutput("ok");
	// 	abort;
	// }

	if (NOT StructKeyExists(arguments,"tagName")){
	 	SearchVals = REMatch("^(\[{1,2}|<)\w+",arguments.text);
	 	if (ArrayLen(SearchVals)) {
	 		arguments.tagName = SearchVals[1];
	 		arguments.tagName = ListFIrst(arguments.tagName,"[]>");
		}
		else {
			throw(message="Unable to parse tag name");
		}
	 	
	}
	// don't bother trying to do this with forward look ups -- they're too buggy (cf9)
	arguments.text = reReplaceNoCase(arguments.text, "(\[{1,2}|<)\/?#arguments.tagName#.*?(\]{1,2}|>)", "", "all");
	
	return arguments.text;
	</cfscript>
	
</cffunction>

<cffunction name="fnGetSqlContainsString" output="no" returntype="struct" hint="Convert google-esque search string to sql contains_search_condition">

	<cfargument name="q" type="string" required="true" hint="Search string">

	<cfset var local = {}>
	
	<!--- add a space at beginning if first item is quoted, so that list splitting works correctly --->
	<cfset local.q = reReplace(trim(arguments.q),"^"""," """)>
	<cfset local.q = reReplace(local.q, "[\(\)]", " ", "all")>
	<cfset local.q = lCase(local.q)>
	<cfset local.searchString = "">
	<cfset local.searchStringNegatives = "">
	<cfset local.nextIsNegative = 0>
	<cfset local.nextIsInclusive = 0>
	<cfset local.nextIsNotFirst = 0>
	<!--- loop quote-delimited list - even items are within quotes, odd not --->
	<cfloop from="1" to="#listLen(local.q,"""")#" index="local.i">
		<cfset local.searchItem = trim(listGetAt(local.q,local.i,""""))>
		<cfif local.searchItem neq "">
			<cfif local.i%2>
				<!--- un-quoted string --->
				<cfset local.nextIsInclusive = 0>
				<cfset local.nextIsNegative = 0>
				<!--- remove negatives, and put into separate string for later --->
				<cfset local.neg = "((^|\s+)(-\s*|(and\s+)?not\s+)|\s*&!\s*)">
				<cfset local.searchNegatives = reMatch(local.neg & "\w+",local.q)>
				<cfloop array="#local.searchNegatives#" index="local.negative">
					<cfset local.negativeS = reReplace(local.negative,local.neg,"")>
					<cfif local.negativeS neq "">
						<cfset local.searchStringNegatives &= """" & local.negativeS & """&!">
					</cfif>
					<cfset local.searchItem = replace(local.searchItem,local.negative,"")>
				</cfloop>
				<!--- if string ends with negation, set flag for next item --->
				<cfset local.endNeg = "(\s+\-|\s+(and)?not|\s*&!)$">
				<cfif reFind(local.endNeg,local.searchItem)>
					<cfset local.nextIsNegative = 1>
					<cfset local.searchItem = reReplace(local.searchItem,local.endNeg,"")>
				</cfif>
				<!--- and similar for inclusivity --->
				<cfset local.endInc = "(\s+and|\s*[&\+])$">
				<cfif reFind(local.endInc,local.searchItem)>
					<cfset local.nextIsInclusive = 1>
					<cfset local.searchItem = reReplace(local.searchItem,local.endInc,"")>
				</cfif>
				<cfif local.searchItem neq "">
					<cfset local.searchItem = """" & local.searchItem>
					<!--- put and/or between each word as appropriate --->
					<cfset local.searchItem = reReplace(local.searchItem, "(^|\b)([^\w\s]*)\s*(and\s+|[&\+]\s*)","\1\2""&""","all")>
					<cfset local.searchItem = reReplace(local.searchItem,"\s+(or\s+)?","""|""","all")>
					<!--- and at the beginning if necessary --->
					<cfset local.searchItem = reReplace(local.searchItem, "^""(&|\|)", "\1")>
					<cfif local.nextIsNotFirst>
						<cfif NOT reFind("^(&|\|)",local.searchItem)>
							<cfif local.nextIsInclusive>
								<cfset local.searchItem = "&" & local.searchItem>
							<cfelse>
								<cfset local.searchItem = "|" & local.searchItem>
							</cfif>
						</cfif>
					<cfelse>
						<cfset local.searchItem = reReplace(local.searchItem, "^(&|\|)", "")>
					</cfif>
					<cfset local.nextIsNotFirst = 1>
					<cfset local.searchString &= local.searchItem & """">
				</cfif>
			<cfelse>
				<!--- quoted string - just put in quotes, with appropriate operators --->
				<cfif local.nextIsNegative>
					<cfset local.searchStringNegatives &= """" & local.searchItem & """&!">
				<cfelse>
					<cfif local.nextIsNotFirst>
						<cfif local.nextIsInclusive>
							<cfset local.searchString &= "&">
						<cfelse>
							<cfset local.searchString &= "|">
						</cfif>
					</cfif>
					<cfset local.nextIsNotFirst = 1>
					<!--- quoted items go straight in, inside quotes --->
					<cfset local.searchString &= """" & local.searchItem & """">
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- remove trailing &! from negatives string --->
	<cfset local.searchStringNegatives = reReplace(local.searchStringNegatives,"&!$","")>
	
	<cfset local.searchInvert = 0>
	<cfif local.searchStringNegatives neq "">
		<cfif local.searchString eq "">
			<cfset local.searchString = reReplace(local.searchStringNegatives,"&!","|","all")>
			<cfset local.searchInvert = 1>
		<cfelse>
			<cfset local.searchString = "(#local.searchString#)&!#local.searchStringNegatives#">
		</cfif>
	</cfif>
	
	<cfset local.ret = {string=local.searchString,invert=local.searchInvert}>
	
	<cfreturn local.ret>

</cffunction>

<cffunction name="fnGetFromStructByKeyValue" output="no" hint="Get a struct from a struct of structs, based on the value of a specific key in the substructs">
	
	<cfargument name="struct" type="struct" required="true">
	<cfargument name="key" type="string" required="true">
	<cfargument name="value" type="string" required="true">
	<cfargument name="all" type="boolean" default="no" hint="Whether to return all occurences as array, or just first">
	
	<cfscript>
	var local = {};
	local.retVal = [];
	
	local.keys = structFindValue(arguments.struct, arguments.value, "all");
	for (local.j = 1; local.j lte arrayLen(local.keys); local.j++) {
		if (listFindNoCase(arguments.key,local.keys[local.j].key)) {
			arrayAppend(local.retVal, local.keys[local.j].owner);
			if (NOT arguments.all) {
				return local.retVal[1];
			}
		}
	}
	return local.retVal;
	</cfscript>

</cffunction>

<cffunction name="fnGetAlphaCodes" output="no" hint="Return unique (nearly) alphanumeric codes">
	
	<cfargument name="length" type="numeric" required="false" default="8" hint="number of characters in code">
	<cfargument name="quantity" type="numeric" required="false" default="1" hint="Number to return. Returned as list">
	
	<cfscript>
	var local = {};
	if (NOT IsDefined("variables.alphaCodes")) {
		variables.alphaCodes = ListToArray("A,B,C,D,E,F,G,H,J,K,M,N,P,Q,R,S,T,U,V,W,X,Y,1,2,3,4,5,6,7,8,9");
	}
	
	local.retVal = ArrayNew(1);
		
	local.charTotal = ArrayLen(variables.alphaCodes);
	local.y = 0;
	for (local.j = 1; local.j lte arguments.quantity; local.j++) {
		local.num = "";
		for (local.z= 1; local.z lte arguments.length; local.z++) {
			do {
				local.k = RandRange(1,local.charTotal);
			}
			while (local.k eq local.y);
			local.num &= variables.alphaCodes[local.k];
			local.y = local.k;
		}
			ArrayAppend(local.retVal,local.num);
		
	}
	
	// convert back to simple scalar.
	if (arguments.quantity eq 1) {
		local.retVal = local.retVal[1]; 
	}
		
	return local.retVal;
	</cfscript>

</cffunction>

<cffunction name="fnIsAjaxRequest" output="false" returntype="boolean" hint="Checks the incoming request headers to see if it is an Ajax request.">
		
	<cfset var requestData = getHTTPRequestData()>
	
	<cfif StructKeyExists(requestData.headers,"X-Requested-With") 
			AND requestData.headers["X-Requested-With"] EQ "XMLHttpRequest"
			OR isDefined("request.isAjax") AND request.isAjax>
				
		<cfreturn true>
		
	<cfelse>
	
		<cfreturn false>
		
	</cfif>		
	
</cffunction>

<cffunction name="SerializeJson" output="false" returntype="string" hint="Fix a few bugs in CF's buggy native SerializeJson">
	<cfargument name="data">

	<cfset var string = SerializeJson(arguments.data)>
	<!--- Coldfusion9 returns invalid JSON - leading 0's are retained, which is not a valid JSON number value --->
	<cfset string = reReplace(string, """:\s*(0\d[\d.]*)",""":""\1""","all")>
	<!--- it also return numbers with trailing period as number which is equally invalid --->
	<cfset string = reReplace(string, "\""\:\s*(\d+\.)\s*([\,\}])",""":""\1""\2","all")>

	<cfreturn string>
</cffunction>

<!---- seems very clik specific.  You probably want to set forceReturn to true. --->
<cffunction name="fnReturnJSON" returntype="void" hint="Outputs the content as a JSON request response if an Ajax request">
	<cfargument name="data" required="true" hint="Data to return">
	<cfargument name="continue" required="false" type="boolean" default="0" hint="Do nothing if not ajax. Otherwise debug and abort (NB default is false will abort)">
	<cfargument name="content_type" required="false" type="string" default="application/json;charset=utf-8" hint="Specify a different MIME type if you want to">
    <cfargument name="forceReturn" required="false" type="boolean" default="0" hint="Always return json no matter whether ajax request or debug or whatever.">

	<cfif arguments.forceReturn OR fnIsAjaxRequest()>
		<cfset local.returnData = this.SerializeJson(arguments.data)>

		<cfcontent reset="true" type="#arguments.content_type#"> <!---   --->
		<cfoutput>#local.returnData#</cfoutput>
        <cfabort>
	<cfelseif NOT arguments.continue>
		<cfsetting showdebugoutput="true" enablecfoutputonly="true">
		<cfif IsDebugMode()>
			<cfoutput>Not Ajax request.</cfoutput>
			<cfdump var="#arguments.data#">
		</cfif>
        <cfabort>
	</cfif>
	
</cffunction>

<cffunction name="fnLoadJSONDataFile" output="false" returntype="any" hint="Loads a JSON file into a struct and returns it.">
		
		<cfargument name="filename" required="true" type="string" hint="Full path to JSON file.">
		<cfargument name="fields" required="false" type="struct" hint="Optionally pass in struct to return field defs">
		
		<cfset var filedata = false>
		<cfset var dataStruct = false>
		
		<cfset filedata = fnReadFile(arguments.filename)>

		<!--- not 100% sure why this is here. Possibly to make readable json files for moustache templates ?? 
		<cfset filedata = reReplace(filedata,"[\r\n]"," ","all")>
		--->
		
		<cftry>
			<cfset dataStruct = DeserializeJSON(filedata)>
			<cfcatch type="any">
				<cfthrow message="Problem deserialising JSON data from file #arguments.filename#" detail="#cfcatch.Message# - #cfcatch.Detail#">
			</cfcatch>
		</cftry>

		<cfif isStruct(dataStruct) AND structKeyExists(dataStruct,"fields")>
			<cfset local.dataDef = ParseJSONDataFields(dataStruct.fields)>
			<cfset structDelete(dataStruct,"fields")>
			<cfloop item="local.row"  collection="#dataStruct#">
				<!--- <cfset StructAppend(dataStruct[local.row],local.fields.defaults,0)> --->
				<cfset JSONDataValidate(dataStruct[local.row],local.dataDef)>
			</cfloop>
			<cfif IsDefined("arguments.fields")>
				<cfset StructAppend(arguments.fields,local.dataDef.fields)>
			</cfif>
		</cfif>
		
		<cfreturn dataStruct>
		
</cffunction>

<cffunction name="getJSONFields" output="false" returntype="struct" hint="Get field defs from JSON data file">
		
	<cfargument name="filename" required="true" type="string" hint="Full path to JSON file.">
	
	<cfset var filedata = false>
	<cfset var dataStruct = false>
	
	<cfset filedata = server.utils.fnReadFile(arguments.filename)>

	<!--- not 100% sure why this is here. Possibly to make readable json files for moustache templates ?? 
	<cfset filedata = reReplace(filedata,"[\r\n]"," ","all")>
	--->
	
	<cftry>
		<cfset dataStruct = DeserializeJSON(filedata)>
		<cfcatch type="any">
			<cfthrow message="Problem deserialising JSON data from file #arguments.filename#" detail="#cfcatch.Message# - #cfcatch.Detail#">
		</cfcatch>
	</cftry>

	<cfif isStruct(dataStruct) AND structKeyExists(dataStruct,"fields")>
		<cfset local.fields = ParseJSONDataFields(dataStruct.fields)>
	<cfelse>
		<cfthrow message="Problem deserialising JSON data from file #arguments.filename#" detail="#cfcatch.Message# - #cfcatch.Detail#">
	</cfif>

	<cfreturn local.fields.fields>

</cffunction>

<cffunction name="JSONDataValidate" output="false" access="private" returntype="void" hint="see fnLoadJSONDataFile(). Validate data using field definition">

	<cfargument name="data" required="true" type="struct" hint="Single data row.">
	<cfargument name="fieldDefs" required="true" type="struct" hint="Field definition struct NB not raw -- must be parsed by ParseJSONDataFields()">

	<cfset var field = false>
	<cfset var value = false>

	<cfset structAppend(arguments.data,arguments.fieldDefs.defaults,false)>

	<cfloop collection="#arguments.fieldDefs.fields#" item="local.fieldName">
		
		<cfset field = arguments.fieldDefs.fields[local.fieldName]>
		
		<cfif field.required AND (NOT structKeyExists(arguments.data,local.fieldName) OR arguments.data[local.fieldName] eq "")>
			<cfthrow type="jsonvalidate" message="Required field #local.fieldName# not specified">
		</cfif>

		<cfset value = arguments.data[local.fieldName]>
		
		<cfswitch expression="#field.type#">
			<cfcase value="text">
				<cfif structKeyExists(field, "max") AND NOT Len(value) lte field.max>
					<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] too long (max #field.max#)">
				</cfif>
				<cfif structKeyExists(field, "min") AND NOT  Len(value) gte field.min>
					<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] too short (min #field.min#)">
				</cfif>
				<cfif structKeyExists(field, "pattern") AND NOT REFindNoCase(field.pattern,value)>
					<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] didn't match pattern #field.pattern#">
				</cfif>
			</cfcase>
			<cfcase value="boolean">
				<cfif NOT IsBoolean(value)>
					<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] not boolean">
				</cfif>
			</cfcase>
			<cfcase value="int,numeric">
				<cfif value neq "">
					<cfif NOT IsNumeric(value) OR (field.type eq "int" AND NOT isInt(value))>
						<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] not #field.type#">
					</cfif>
					<cfif structKeyExists(field, "max") AND NOT value lte field.max>
						<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] too high (max #field.max#)">
					</cfif>
					<cfif structKeyExists(field, "min") AND NOT  value gte field.min>
						<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] too low (min #field.min#)">
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="list,multi">
				<cfif field.type eq "list" AND ListLen(value) gt 1>
					<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] had multiple entries">
				</cfif>
				<cfloop index="local.val" list="#value#">
					<cfif NOT structKeyExists(field.list,local.val)>
						<cfthrow type="jsonvalidate" message="Specified value for #local.fieldName# [#value#] not in allowed list values">	
					</cfif>
				</cfloop>
			</cfcase>

		</cfswitch>

	</cfloop>

</cffunction>

<cffunction name="ParseJSONDataFields" output="false" access="private" returntype="struct" hint="see fnLoadJSONDataFile(). Parse the fields def for json data file">

	<cfargument name="fields" required="true" type="struct" hint="Field definition struct">

	<cfset var field = false>

	<cfset var retFields = {"fields"=arguments.fields,"defaults"={}}>
	<cfloop collection="#arguments.fields#" item="local.fieldID">
		<cfset field = retFields.fields[local.fieldID]>
		<cfif StructKeyExists(field,"default")>
			<cfset retFields.defaults[local.fieldID] = field.default>
		</cfif>
		<cfif NOT StructKeyExists(field,"label")>
			<cfset field["label"] = labelFormat(local.fieldID)>
		</cfif>
		<cfset structAppend(field,{"required"=0,"type"="text","description"="","sort_order"=0},false)>
		<cfif field.type eq "list">
			<cfif NOT structKeyExists(field, "list") OR NOT IsStruct(field.list)>
				<cfthrow message="List values incorrect for field #local.fieldID#">
			</cfif>
			<cfset local.sort_order = 10>
			<cfloop item="local.listID" collection="#field.list#">
				<cfif IsSimpleValue(field.list[local.listID])>
					<cfset field.list[local.listID] = {"display"= field.list[local.listID],"sort_order"=local.sort_order}>
				</cfif>
				<cfset local.sort_order += 10>
			</cfloop>
		</cfif>
	</cfloop>

	<cfreturn retFields>

</cffunction>



<cffunction name="fnJsonQuery" output="false" returntype="array" hint="Takes a json serialized cf query and converts it into an array of structs">
		
		<cfargument name="data" required="true" type="struct" hint="Struct with keys columns and data">
		
		<cfset var columns = {}>
		<cfset var retdata = []>
		
		
		<cfloop index="local.row" Array="#arguments.data.data#">
			<cfset local.record = {}>

			<cfloop index="local.i" from="1" to="#ArrayLen(arguments.data.columns)#">
				<cfif ArrayIsDefined(local.row,local.i)>
					<cfset local.record[data.columns[local.i]] = local.row[local.i]>
				<cfelse>
					<cfset local.record[data.columns[local.i]] = "">
				</cfif>
			</cfloop>

			<cfset arrayAppend(retdata,local.record)>

		</cfloop>

		<cfreturn retdata>
		
</cffunction>

<cffunction name="xml2Struct" hint="DEPRECATED (see xml2Data). Parse XML into a Struct of Structs." description="Take a basic XML doc and parse the child nodes into a struct of structs. The results are keyed by rownumber or an
	attribute specified by the 'key' argument. A key attribute to the top level tag can also be specified with the same affect. A simple sub tag on its own with just text in it will be added to the struct as
		 a simple key->value pair. Multiple child tags will be added as structs converted by the same function.">
		
	<cfargument name="xmlData" required="yes" hint="Either XML as produced by parseXML or else an array of XML nodes (the latter should only be used when recursing)">
	<cfargument name="key" required="no"  hint="supply a key argument here to key the results by the value of this attribute instead of the row number. XML attribute will OVERRIDE this value.">
	<cfargument name="returnType" required="false" default="struct" hint="array|struct if set to array the data will be return as array, rather than struct, to maintain ordering. The 'key' argument will have no effect">
	
	<cfset var retData = {}>
	<cfset var basetag = "">
	<cfset var row = "">
	<cfset var field = "">
	<cfset var columnStruct = {}>
	<cfset var rowVals = {}>
	<cfset var local = {}>
	<cfset var rowNum = 0>
	<cfset var fieldName = "">
	<cfset var subNode = {}>
	<cfset var anyStruct = {}>
	
	<cfif returnType eq 'array'>
		<cfset retData = arrayNew(1)>
	</cfif>
	
	<!--- data parsed when recursing will be an array of XML nodes --->
	<cfif IsArray(arguments.xmlData)>
		<cfset local.arrData = arguments.xmlData>
	<cfelse>
		<!--- MUST be only one base tag. Simplest way of getting this is StructKeyList! --->
		<cfset basetag = StructKeyList(arguments.xmlData)>
		<cfset local.arrData = arguments.xmlData[basetag].xmlChildren>
		<cfif StructKeyExists(arguments.xmlData[basetag].XMLAttributes,"key")>
			<cfset arguments.key = arguments.xmlData[basetag].XMLAttributes["key"]>
		</cfif>
	</cfif>
	
	<!--- Loop over every child tag --->
	<cfloop index="row" array="#local.arrData#">
		
		<!--- must duplicate here or we get some very funny errors trying to access the data --->
		<cfset rowVals = xmlAttributes2Struct(row.XMLAttributes)>
		<cfset rowNum += 1>
		
		<!--- recurse through child tags . A simple sub tag on its own with just text in it will be added to the struct as
		 a simple key->value pair. Multiple tags or nested structures will be added as Structs. --->
		<cfif StructKeyExists(row,"xmlChildren")>
			
			<cfloop index="field" array="#row.xmlChildren#">
				
				<cfif ArrayLen(field.xmlChildren) gte 1>
					<cfif StructKeyExists(field.XMLAttributes,"key")>
						<cfset subNode = Duplicate(XML2Struct(field.xmlChildren,field.XMLAttributes.key,arguments.returnType))>
					<cfelse>
						<cfset subNode = Duplicate(XML2Struct(xmlData = field.xmlChildren,returnType = arguments.returnType))>
					</cfif>
					
					<cfset rowVals[field.XmlName] = subNode>
				<cfelse>
					
					<cfset rowVals[field.XmlName] = reReplace(field.xmlText,"([\n\r])\t+","\1","all")>

					<!--- Guess data type. --->
					<cfif isNumeric(rowVals[field.XmlName])>
						<cfset rowVals[field.XmlName] = Val(rowVals[field.XmlName])>
					<cfelseif isBoolean(rowVals[field.XmlName])>
						<cfset rowVals[field.XmlName] = NOT NOT rowVals[field.XmlName]>
					<cfelse>
						<cfset rowVals[field.XmlName]= rowVals[field.XmlName]>
					</cfif>
					
				</cfif>
				
			</cfloop>
			
		</cfif>
		
		<!--- key results by row num if no key specified --->
		<cfif NOt IsDefined("arguments.key")>
			<cfset local.key = rowNum>
		<cfelse>
			<cfif NOT StructKeyExists(rowVals,arguments.key)>
				<cfthrow message="Value specified as key [#arguments.key#] not defined for row #rowNum#">
			</cfif>
			<cfset local.key = rowVals[arguments.key]>
		</cfif>
						
		<cfswitch expression="#arguments.returnType#">
			<cfcase value="struct">
		<cfset retData[local.key] = Duplicate(rowVals)>
			</cfcase>
			<cfcase value="array">
				<cfset arrayAppend(retData, duplicate(rowVals))>
			</cfcase>
		</cfswitch>
		
	</cfloop>
	
	<cfreturn retData>

</cffunction>

<cffunction name="dspTickMark" output="no" returntype="string" hint="Evaluates a condition and shows a tick mark if true or a blank if not">
	<cfargument name="condition" required="true" hint="A condition - shows tick if true, blank if not">
	<cfargument name="size" required="no" default="small" hint="Return a slightly bigger tick with 'big'">
	
	<cfset var retData = "&nbsp;">
	
	<cfif arguments.condition>
		<cfswitch expression="#arguments.size#">	
			<cfcase value="big">
			<cfset retData ="&##10004;">
			</cfcase>
			<cfdefaultcase>
			<cfset retData = "&##10003;">
			</cfdefaultcase>
		</cfswitch>
	</cfif>
	<cfreturn retData>
</cffunction>

<cffunction name="fnLabelFormat" output="no" returntype="string" hint="Make a display label from a field code etc">
	<cfargument name="code" required="true" hint="Field code. Underscores are replaced with spaces, text is formatted in Title Case.">
	<cfset arguments.code = Replace(arguments.code, "_", " ", "all")>
	<cfset arguments.code = UCase(left(arguments.code, 1)) & LCase(right(arguments.code, Len(arguments.code) - 1))>
	<cfreturn arguments.code>
</cffunction>

<cffunction name="hmacEncrypt" returntype="binary" access="public" output="false">
   <cfargument name="signKey" type="string" required="true" />
   <cfargument name="signMessage" type="string" required="true" />

   <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
   <cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />

   <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
   <cfset var mac = createObject("java","javax.crypto.Mac") />

   <cfset key = key.init(jKey,"HmacSHA1") />

   <cfset mac = mac.getInstance(key.getAlgorithm()) />
   <cfset mac.init(key) />
   <cfset mac.update(jMsg) />

   <cfreturn mac.doFinal() />
</cffunction>

<cffunction name="oauthEncodedFormat" returntype="string" output="false" hint="Encode a string for oauth (RFC3986)">
	<cfargument name="string" type="string" required="true">
	<cfreturn replacelist(urlencodedformat(string), "%2D,%2E,%5F,%7E", "-,.,_,~")>
</cffunction>

<cffunction name="parseQueryString" returntype="struct" output="false" hint="Parse a query string">
	<cfargument name="string" type="string" required="true">
	
	<cfset var local = {}>
	<cfset local.retVal = {}>
	
	<cfloop list="#arguments.string#" delimiters="&" index="local.item">
		<cfif listLen(local.item,"=") gt 1>
			<cfset local.retVal[urlDecode(listFirst(local.item,"="))] = urlDecode(listLast(local.item,"="))>
		<cfelse>
			<cfset local.retVal[urlDecode(listFirst(local.item,"="))] = "">
		</cfif>
	</cfloop>
	
	<cfreturn local.retVal>
</cffunction>

<cffunction name="structKeyListFind" output="false" returntype="boolean" hint="Check whether any of a list of keys exist in a struct">
	<cfargument name="keys" type="string" required="true">
	<cfargument name="struct" type="struct" required="true">
	<cfset var key = {}>
	<cfloop list="#arguments.keys#" index="key">
		<cfif structKeyExists(arguments.struct, key)>
			<cfreturn true>
		</cfif>
	</cfloop>
	<cfreturn false>
</cffunction>

<cffunction name="fnStructToQuery" output="false" returntype="query" hint="Convert a struct to a one-row query">
	<cfargument name="struct" type="struct" required="true">
	<cfargument name="query" default="#queryNew("")#">
	
	<cfset var local = {}>
	
	<cfloop collection="#arguments.struct#" item="local.key">
		<cfif isSimpleValue(arguments.struct[local.key])>
			<cfif isDefined("arguments.query.#local.key#")>
				<cfset local.fieldVal = arguments.struct[local.key]>
				<cfif local.fieldVal eq "NULL">
					<cfset local.fieldVal = "">
				</cfif>
				<cfset querySetCell(arguments.query, local.key, local.fieldVal)>
			<cfelse>
				<cfset local.cell = []>
				<cfset local.cell[arguments.query.recordCount+1] = arguments.struct[local.key]>
				<cfset queryAddColumn(arguments.query, local.key, iif(isNumeric(arguments.struct[local.key]) OR isBoolean(arguments.struct[local.key]), "'INTEGER'", "'VARCHAR'"), local.cell)>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfreturn arguments.query>
</cffunction>

<cffunction name="fnStructToQueryCols" output="false" returntype="query" hint="Convert a struct to a two column query">
	<cfargument name="struct" type="struct" required="true">
	<cfargument name="columns" default="value,display">
	
	<cfset var local = {}>
	<cfset var tmpQuery = {}>

	<cfset local.arrKey =  Arraynew(1)>
	<cfset local.arrVal =  Arraynew(1)>

	<cfloop collection="#arguments.struct#" item="local.key">
		
		<cfset ArrayAppend(local.arrKey,local.key)>
		<cfset ArrayAppend(local.arrVal,arguments.struct[local.key])>
		
	</cfloop>
	
	<cfset local.keyType = "VarChar">
	<cfset local.valType = "VarChar">
	<cfif ListLast(ListFirst(arguments.columns),"_") eq "id">
		<cfset local.keyType = "Integer">
	</cfif>

	<cfset tmpQuery = QueryNew("")>
	<cfset queryAddColumn(tmpQuery, ListFirst(arguments.columns), local.keyType, local.arrKey)>
	<cfset queryAddColumn(tmpQuery, ListLast(arguments.columns), local.valType, local.arrVal)>	

	<cfquery name="local.bugFix" dbtype="query">
	SELECT  [#ListFirst(arguments.columns)#], [#ListLast(arguments.columns)#]
	FROM    tmpQuery
	</cfquery> 

	<cfreturn local.bugFix>

</cffunction>


<cffunction name="fnStructOfStructsToQuery" output="false" returntype="query" hint="Convert a struct of similar structs to a multi-row query (required same keys for each substruct)">
	<cfargument name="struct" type="struct" required="true">
	
	<cfset var local = {}>
	<!--- use first struct to construct query, then discard that data --->
	<cfset local.sampleRow = arguments.struct[listFirst(structKeyList(arguments.struct))]>
	
	<cfset local.query = fnStructToQuery(local.sampleRow)>
	
	<cfquery dbtype="query" name="local.query">
	SELECT	'' as ID, *
	FROM	[local].query
	WHERE	1 = 0
	</cfquery>
	
	<cfloop collection="#arguments.struct#" item="local.rowID">
		<cfset queryAddRow(local.query)>
		<cfset local.row = Duplicate(arguments.struct[local.rowID])>
		<cfset local.row.ID = local.rowID>
		<cfset fnStructToQuery(local.row, local.query)>
	</cfloop>
	
	<cfreturn local.query>

</cffunction>

<cffunction name="fnDataFileToQuery" output="false" returntype="query" hint="Convert tabbed text data file with header row to query.">

	<cfargument name="filename" required="true">	

	<cfset var local = {}>
	<cfset local.fileData = fnReadFile(arguments.filename)>
	<cfset local.strData = {}>
	<cfset local.rowNum = 1>
	<cfloop index="local.line" list="#local.fileData#"  delimiters="#chr(13)##chr(10)#">
		<cfif local.rowNum eq 1>
			<cfset local.fieldNames = ArrayNew(1)>
			<cfloop index="local.field" list="#local.line#"  delimiters="#chr(9)#">
				<cfset ArrayAppend(local.fieldNames,local.field)>
			</cfloop>
		<cfelse>
			<cfset local.Row = {}>
			<cfset local.fieldNum = 1>
			<cfloop index="local.field" list="#local.line#"  delimiters="#chr(9)#">
				<cfset local.Row[local.fieldNames[local.fieldNum]] = local.field>
				<cfset local.fieldNum += 1>
			</cfloop>
			<cfset local.strData[local.rowNum]= local.Row>
		</cfif>
		<cfset local.rowNum += 1>
	</cfloop>

	<cfset local.retQuery = fnStructOfStructsToQuery(local.strData)>

	<cfreturn local.retQuery>
</cffunction>

<cffunction name="randomRows" hint="return x different random numbers between 1 and maxrows">
	<cfargument name="maxrows" required="yes" hint="Total number of rows">	
	<cfargument name="numrows" required="yes" hint="Number of rows to return">	
	
	<cfscript>
	var i = StructNew();
	randomize(timeFormat(now(),"ssmmhh"),"SHA1PRNG");
	if (arguments.numrows gt arguments.maxrows) arguments.numrows = arguments.maxrows;
	while (StructCount(i) lt arguments.numrows) {
		i[RandRange(1,arguments.maxrows)] = 1;
	}
	return StructKeyList(i);
	</cfscript>

</cffunction>

<cffunction name="reEscape" output="no" returntype="string" hint="Escape a string for use in regex">
	<cfargument name="string" type="string" required="true">
	
	<cfreturn reReplace(string, "[.*+?^${}()|[\]/\\]", "\\\0", "ALL")>
</cffunction>

<cffunction name="trackLink" output="no" returntype="string" hint="Generate an A tag with javascript for tracking a download in Google Analytics">
	<cfargument name="link" type="string" required="true">
	<cfargument name="text" type="string" required="no" hint="Text of link - default is URL">
	<cfargument name="category" type="string" required="no" hint="A name that you supply as a way to group objects that you want to track. Default is extensions of filename">
	<cfargument name="action" type="string" required="no" default="download" hint="Use the action parameter to name the type of event or interaction you want to track for a particular web object.">
	<cfargument name="label" type="string" required="no" hint="With labels, you can provide additional information for events that you want to track, such as the movie title. Default is href attribute">
	<cfargument name="target" type="string" required="no" hint="Link target - use none or _blank">
	<cfargument name="class" type="string" required="no" hint="CSS class to apply to A tag">
	<cfargument name="title" type="string" required="no" hint="Title attribute to apply to A tag">
	<cfargument name="tracklink" type="any" required="no" default="Yes" hint="Supply false or blank value to just return normal link. Used when not tracking (e.g. dev server)">
	
	<cfset var retVal = "<a href=""#arguments.link#""">
	<cfset var local = {}>

	<cfif NOT IsDefined("arguments.text")>
		<cfset arguments.text = ReReplace(arguments.link,"https?\:\/\/","")>
	</cfif>
	<cfif NOT IsDefined("arguments.category")>
		<cfset arguments.category = ListLast(arguments.link,".")>
	</cfif>

	<!--- tracklink can be blank or non-blank for false or true --->
	<cfif Trim(arguments.tracklink) eq "">
		<cfset  arguments.trackLink= 0>
	<cfelseif NOT IsBoolean(arguments.tracklink)>
		<cfset  arguments.trackLink= 1>
	</cfif>
	
	<cfif arguments.tracklink>

		<!--- default for label is to dynamically get href at runtime --->
		<cfif IsDefined("arguments.label")>
			<cfset local.labelAttr = "'#arguments.label#'">
		<cfelse>
			<cfset local.labelAttr = "this.href">
		</cfif>

		<cfset local.script = "_gaq.push(['_trackEvent','#arguments.category#','#arguments.action#',#local.labelAttr#]);">
		

		<cfif NOT IsDefined("arguments.target")>
			<!--- delay link request to give analytics time to run --->
			<cfset local.script = "var that=this;#local.script#setTimeout(function(){location.href=that.href;},200);return false;">
		<cfelse>
			<cfset retVal &= " target=""#arguments.target#""">
		</cfif>

		<cfset retVal &= " onclick=""#local.script#""">
	<!---cfelse>
		<cftrace text="tracklink is off"--->
	<cfelseif isDefined("arguments.target")>
		<cfset retVal &= " target=""#arguments.target#""">
	</cfif>
	
	<cfif IsDefined("arguments.class")>
		<cfset retVal &= " class=""#arguments.class#""">
	</cfif>

	<cfif IsDefined("arguments.title")>
		<cfset retVal &= " title=""#arguments.title#""">
	</cfif>

	<cfset retVal &= ">#arguments.text#</a>">

	<!---cftrace text="retval=#HTMLEditFormat(retval)#"--->

	<cfreturn retVal>

</cffunction>

<cffunction name="hasValue" returntype="boolean" hint="Test struct Keys for for existence and non blankness (or emptiness). Values can be simple, arrays or structs">
	
	<cfargument name="sStr" type="struct" required="true" hint="Struct">
	<cfargument name="key" type="string" required="true" hint="Struct">	

	<cfset var retVal = true>

	<cfif NOT StructKeyExists(arguments.sStr, arguments.key)>
		<cfset retVal = false>
	<cfelse>
		<cfif isSimpleValue(arguments.sStr[arguments.key]) AND arguments.sStr[arguments.key] eq "">
			<cfset retVal = false>
		<cfelseif isStruct(arguments.sStr[arguments.key])  AND StructIsEmpty(arguments.sStr[arguments.key])>
			<cfset retVal = false>
		<cfelseif isArray(arguments.sStr[arguments.key])  AND NOT ArrayLen(arguments.sStr[arguments.key])>
			<cfset retVal = false>
		</cfif>	
	</cfif>

	<cfreturn retVal>

</cffunction>

<cffunction name="listToStruct" returntype="struct" hint="Convert list to struct (values are 1)">
	
	<cfargument name="sList" type="string" required="true" hint="List to convert">
	<cfargument name="delimiters" type="string" required="false" default=",">

	<cfset var i = 0>
	<cfset var retVal = {}>

	<cfloop list="#arguments.sList#" index="i" delimiters="#arguments.delimiters#">
		<cfset retVal[i] = 1>
	</cfloop>

	<cfreturn retVal>

</cffunction>

<cffunction name="listReverse" returntype="string" hint="Reverse a list">
	<cfargument name="slist" required="yes">
	<cfargument name="delimiter" required="no" default=",">

	<cfset var local = {}>
	<cfset var myList = "">
	<cfloop from="#ListLen(arguments.slist,arguments.delimiter)#" to="1" step="-1" index="local.i">
		<cfset local.val = ListGetAt(arguments.slist,local.i,arguments.delimiter)>
		<cfset myList=ListAppend(myList,local.val,arguments.delimiter)>
	</cfloop>
	
	<cfreturn myList>

</cffunction>

<cffunction name="internetDomain" returntype="struct" hint="Parse TLD [TLD], top private domain and [TPD], and sub domain [SUB] from an internet domain">
	
	<cfargument name="domainName" required="yes">

	<cfset var local = {}>
	<cfset var retVal = {}>
	
	<cfset arguments.domainName = ReReplace(arguments.domainName,"http\:\/\/(s)?","")>
	<cfoutput>#arguments.domainName#</cfoutput><br>

	<cfif NOT StructKeyExists(server,"TLDs")>
		<cfset local.tlds = {}>
		<cffile action="read" file="#GetDirectoryFromPath(getCurrentTemplatePath())#/effective_tld_names.dat" variable="local.data">

		<cfloop index="local.line" list="#local.data#" delimiters="#chr(13)##chr(10)#">
			<cfif NOT Left(trim(local.line),2) eq "//">
				<cfif ListLen(local.line,".") eq 1>
					<cfset local.currentAuthority = Trim(ListFirst(local.line,"."))>
					<cfif NOT StructKeyExists(local.tlds, local.currentAuthority)>
						<cfset local.tlds[local.currentAuthority] = {}>
					</cfif>
				</cfif>
				
				<cfset local.tlds[local.line] = local.currentAuthority>
			</cfif>
		</cfloop>

		<cfset server.TLDs = local.TLDs>
	</cfif>

	<cfset local.top = "">
	<cfset local.urlReverse = ListReverse(arguments.domainName,".")>
	<cfoutput>#local.urlReverse#</cfoutput>
	
	<cfloop index="local.i" from="1" to="#ListLen(arguments.domainName,".") - 1#">
		<cfset local.top = ListPrepend(ListGetAt(local.urlReverse,local.i,"."),".")>
		<cfif StructKeyExists(server.TLDs,local.top)>
			<cfset retVal.TLD = local.top>
			<cfset retVal.TPD = ListGetAt(local.urlReverse,local.i + 1)>
			<cfset retVal.sub = "">
			<cfif local.i + 1 lt ListLen(local.urlReverse,".")>
				<cfloop  from = "1" to="#ListLen(local.domainName,".")-local.i-1#" index="local.j">
					<cfset retVal.sub = ListAppend(ListGetAt(local.domainName,local.j),".")>
				</cfloop>
			</cfif>
		</cfif>

	</cfloop>
	
	<cfreturn retVal>

</cffunction>

<cffunction name="newStack">
	
	<cfscript>
	var local = {};
	local.stack =   CreateObject("component","cfscript.stack");
	local.stack.init();
	return local.stack;
	</cfscript>
	
</cffunction>

<cffunction name="fnArraySplice">
	
	<cfargument name="vArray" required="true">
	<cfargument name="start" required="true" hint="positive int to get elements from start to end or negative into to get last x elements">
	<cfargument name="end" required="false" hint="positive int to get elements from start to end or negative into to get last x elements">

	<cfscript>
	local.retList = ArrayNew(1);
	
	local.arrLen = ArrayLen(arguments.vArray);
	if (NOT local.arrLen) return local.retList;
	 
	if (arguments.start lt 1) {
		arguments.start = local.arrLen - arguments.start;
	}
	if (NOT StructKeyExists(arguments,"end") OR arguments.end gt local.arrLen) {
		arguments.end = local.arrLen;
	}
	else {
		if (arguments.end lt 1) {
			arguments.end = local.arrLen - arguments.end;
		}
	}
	if (arguments.end lt arguments.start) {
		throw("End #arguments.end# is lt start #arguments.start# for arraySplice");
	}
	for (local.i = arguments.start; local.i lte arguments.end; local.i += 1) {
		ArrayAppend(local.retList,arguments.vArray[local.i]);
	}
	return local.retList;
	</cfscript>
	
</cffunction>

<!---
 Serialize native ColdFusion objects into a JSON formated string.
 
 @param arg      The data to encode. (Required)
 @return Returns a string. 
 @author Jehiah Czebotar (jehiah@gmail.com) 
 @version 2, June 27, 2008 
--->
<cffunction name="jsonencode" access="remote" returntype="string" output="No"
        hint="Converts data from CF to JSON format">
    <cfargument name="data" type="any" required="Yes" />
    <cfargument name="queryFormat" type="string" required="No" default="query" /> <!-- query or array -->
    <cfargument name="queryKeyCase" type="string" required="No" default="lower" /> <!-- lower or upper -->
    <cfargument name="stringNumbers" type="boolean" required="No" default=false >
    <cfargument name="formatDates" type="boolean" required="No" default=false >
    <cfargument name="columnListFormat" type="string" required="No" default="string" > <!-- string or array -->
    
    <!--- VARIABLE DECLARATION --->
    <cfset var jsonString = "" />
    <cfset var tempVal = "" />
    <cfset var arKeys = "" />
    <cfset var colPos = 1 />
    <cfset var i = 1 />
    <cfset var column = ""/>
    <cfset var datakey = ""/>
    <cfset var recordcountkey = ""/>
    <cfset var columnlist = ""/>
    <cfset var columnlistkey = ""/>
    <cfset var dJSONString = "" />
    <cfset var escapeToVals = "\\,\"",\/,\b,\t,\n,\f,\r" />
    <cfset var escapeVals = "\,"",/,#Chr(8)#,#Chr(9)#,#Chr(10)#,#Chr(12)#,#Chr(13)#" />
    
    <cfset var _data = duplicate(arguments.data) />

    <!--- BOOLEAN --->
    <cfif IsBoolean(_data) AND NOT IsNumeric(_data) AND NOT ListFindNoCase("Yes,No", _data)>
        <cfreturn LCase(ToString(_data)) />
        
    <!--- NUMBER --->
    <cfelseif NOT arguments.stringNumbers AND IsNumeric(_data) AND NOT REFind("^0+[^\.]",_data)>
        <cfreturn ToString(_data) />
    
    <!--- DATE --->
    <cfelseif IsDate(_data) AND arguments.formatDates>
        <cfreturn '"#DateFormat(_data, "medium")# #TimeFormat(_data, "medium")#"' />
    
    <!--- STRING --->
    <cfelseif IsSimpleValue(_data)>
        <cfreturn '"' & ReplaceList(_data, escapeVals, escapeToVals) & '"' />
    
    <!--- ARRAY --->
    <cfelseif IsArray(_data)>
        <cfset dJSONString = createObject('java','java.lang.StringBuffer').init("") />
        <cfloop from="1" to="#ArrayLen(_data)#" index="i">
            <cfset tempVal = jsonencode( _data[i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
            <cfif dJSONString.toString() EQ "">
                <cfset dJSONString.append(tempVal) />
            <cfelse>
                <cfset dJSONString.append("," & tempVal) />
            </cfif>
        </cfloop>
        
        <cfreturn "[" & dJSONString.toString() & "]" />
    
    <!--- STRUCT --->
    <cfelseif IsStruct(_data)>
        <cfset dJSONString = createObject('java','java.lang.StringBuffer').init("") />
        <cfset arKeys = StructKeyArray(_data) />
        <cfloop from="1" to="#ArrayLen(arKeys)#" index="i">
            <cfset tempVal = jsonencode( _data[ arKeys[i] ], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
            <cfif dJSONString.toString() EQ "">
                <cfset dJSONString.append('"' & arKeys[i] & '":' & tempVal) />
            <cfelse>
                <cfset dJSONString.append("," & '"' & arKeys[i] & '":' & tempVal) />
            </cfif>
        </cfloop>
        
        <cfreturn "{" & dJSONString.toString() & "}" />
    
    <!--- QUERY --->
    <cfelseif IsQuery(_data)>
        <cfset dJSONString = createObject('java','java.lang.StringBuffer').init("") />
        
        <!--- Add query meta data --->
        <cfif arguments.queryKeyCase EQ "lower">
            <cfset recordcountKey = "recordcount" />
            <cfset columnlistKey = "columnlist" />
            <cfset columnlist = LCase(_data.columnlist) />
            <cfset dataKey = "data" />
        <cfelse>
            <cfset recordcountKey = "RECORDCOUNT" />
            <cfset columnlistKey = "COLUMNLIST" />
            <cfset columnlist = _data.columnlist />
            <cfset dataKey = "data" />
        </cfif>
        
        <cfset dJSONString.append('"#recordcountKey#":' & _data.recordcount) />
        <cfif arguments.columnListFormat EQ "array">
            <cfset columnlist = "[" & ListQualify(columnlist, '"') & "]" />
            <cfset dJSONString.append(',"#columnlistKey#":' & columnlist) />
        <cfelse>
            <cfset dJSONString.append(',"#columnlistKey#":"' & columnlist & '"') />
        </cfif>
        <cfset dJSONString.append(',"#dataKey#":') />
        
        <!--- Make query a structure of arrays --->
        <cfif arguments.queryFormat EQ "query">
            <cfset dJSONString.append("{") />
            <cfset colPos = 1 />
            
            <cfloop list="#_data.columnlist#" delimiters="," index="column">
                <cfif colPos GT 1>
                    <cfset dJSONString.append(",") />
                </cfif>
                <cfif arguments.queryKeyCase EQ "lower">
                    <cfset column = LCase(column) />
                </cfif>
                <cfset dJSONString.append('"' & column & '":[') />
                
                <cfloop from="1" to="#_data.recordcount#" index="i">
                    <!--- Get cell value; recurse to get proper format depending on string/number/boolean data type --->
                    <cfset tempVal = jsonencode( _data[column][i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
                    
                    <cfif i GT 1>
                        <cfset dJSONString.append(",") />
                    </cfif>
                    <cfset dJSONString.append(tempVal) />
                </cfloop>
                
                <cfset dJSONString.append("]") />
                
                <cfset colPos = colPos + 1 />
            </cfloop>
            <cfset dJSONString.append("}") />
        <!--- Make query an array of structures --->
        <cfelse>
            <cfset dJSONString.append("[") />
            <cfloop query="_data">
                <cfif CurrentRow GT 1>
                    <cfset dJSONString.append(",") />
                </cfif>
                <cfset dJSONString.append("{") />
                <cfset colPos = 1 />
                <cfloop list="#columnlist#" delimiters="," index="column">
                    <cfset tempVal = jsonencode( _data[column][CurrentRow], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
                    
                    <cfif colPos GT 1>
                        <cfset dJSONString.append(",") />
                    </cfif>
                    
                    <cfif arguments.queryKeyCase EQ "lower">
                        <cfset column = LCase(column) />
                    </cfif>
                    <cfset dJSONString.append('"' & column & '":' & tempVal) />
                    
                    <cfset colPos = colPos + 1 />
                </cfloop>
                <cfset dJSONString.append("}") />
            </cfloop>
            <cfset dJSONString.append("]") />
        </cfif>
        
        <!--- Wrap all query data into an object --->
        <cfreturn "{" & dJSONString.toString() & "}" />
    
    <!--- UNKNOWN OBJECT TYPE --->
    <cfelse>
        <cfreturn '"' & "unknown-obj" & '"' />
    </cfif>
</cffunction>


<cffunction name="htmlformat" access="remote" returntype="string" output="No"
        hint="Converts plain text to html replacing line endings with <br>. Sanitize using jsoup if possible. NB for anything
        more complicated, fire up markdown.cfc and use that.">
    
    <cfargument name="text" type="string" required="Yes" >
    <cfargument name="jsoup" type="boolean" required="No" default="1" hint="Try and sanitize using jsoup">

    <cfset arguments.text = Replace(Trim(arguments.text),chr(13) & chr(10),chr(13),"all")>
	<cfset arguments.text = Replace(arguments.text,chr(10),chr(13),"all")>
	<cfset arguments.text = Replace(arguments.text,chr(13),"{cr}","all")>

    <cfif arguments.jsoup>
		
		<cftry>
			<cfif NOT isDefined("server.jsoup")>
				<cfobject component="jsoup.jsoup" name="server.jsoup">
				<cfset server.jsoup.init()>
			</cfif>
			
			<cfset arguments.text = server.jsoup.clean(arguments.text,"simpleText")>

			<cfcatch>
			<cfrethrow>
				<!--- just ignore --->
			</cfcatch>
		</cftry>

	</cfif>

	<cfset arguments.text = Replace(arguments.text,"{cr}","<br>","all")>

	<cfreturn arguments.text>

</cffunction>

<cffunction name="fnYUICompressor" output="No" returntype="void" hint="Uses the Yahoo YUI Compressor to reduce the size of JavaScript and CSS files.">

	<cfargument name="file" required="Yes" type="string" hint="Path to the file to be compressed">
	<cfargument name="outfile" required="No" type="string" hint="Path to the file to output.">
	<cfargument name="combineFiles" required="false" type="boolean" default="false" hint="returns the combined files if true">
	
	<cfset var local = StructNew()>

	<cfset local.minExt = "yui">
	
	<cfif NOT StructKeyExists(arguments, "outfile")>
		<cfset local.ext = ListLast(arguments.file,".")>		
		<cfset arguments.outfile = REReplaceNoCase(arguments.file,"\.#local.ext#$",".#local.minExt#.#local.ext#")>
	</cfif>
	
	<cfif arguments.combineFiles>
		<cfset local.combinedFile = ''>
		<cfloop list="#arguments.file#" index="local.name">
			<cfif NOT FileExists(local.name)>
				<cfthrow message="File not found." detail="File #local.name# was not found.">
			</cfif>
			<cffile action="read" file="#local.name#" variable="local.temp" charset="UTF-8">
			<cfset local.combinedFile &= local.temp>
		</cfloop>
		<cfset arguments.file=arguments.outfile>
		<cffile action="write" file="#arguments.outfile#" output="#local.combinedFile#" charset="UTF-8">
	<!--- <cfelse> --->
	</cfif>

	<cfif NOT FileExists(arguments.file)>
		<cfthrow message="File not found." detail="File #arguments.file# was not found.">
	</cfif>
			
	<cfset local.jsCompressArgs = arguments.file &" -o " & arguments.outfile >
	<cfset local.jsCompressArgs = replace(local.jsCompressArgs, "\", "/", 'all')>
		
	<cfset local.yuiArgs = JavaCast("String[]",ListToArray(local.jsCompressArgs, " "))>

	<!--- <cfset fnLog('calling yui compressor with these arguments: "#local.jsCompressArgs#"',"i","yui")> --->
	
	<cfscript>
	//local.yuiObj = CreateObject("java","com.yahoo.platform.yui.compressor.YUICompressor");
	
	// Yahoo JavaScript and CSS compressor.
	if (NOT IsDefined("variables.yuiObj")) {
		try {
			variables.yuiObj = CreateObject("java","com.yahoo.platform.yui.compressor.YUICompressor");
		}
		catch(Any e) {
			throw(e.message,e.detail);
			//fnLog("YUI JavaScript/CSS compressor not loaded. Cannot load class com.yahoo.platform.yui.compressor.YUICompressor");
		}
	}
	variables.yuiObj.main(local.yuiArgs);
	</cfscript>

</cffunction>

<cffunction name="jsoup" hint="Create a jsoup object from file or URL" returntype="any">
	<cfargument name="filePath" hint="Path to file to load">
	<cfargument name="urlPath" hint="URL to download">

	<cfscript>
	var local = {};
	
	if (NOT StructKeyExists(this,"jSoupClass")) {
		this.jSoupClass = createObject( "java", "org.jsoup.Jsoup" );
	}
	if (StructKeyExists(arguments,"filePath")) {
		
		local.htmlStr = fnReadFile(arguments.filePath);
		local.doc = this.jSoupClass.parse(local.htmlStr);
	}
	else if (StructKeyExists(arguments,"filePath")) {
		local.doc = this.jSoupClass.get(arguments.urlPath);
	}
	else {
		throw("filePath or urlPath must be defined when using jsoup");
	}
	return local.doc;
	</cfscript>

</cffunction>

<cfscript>
// generate an MD5 checksum for binary content
// typically you would fnReadFile(...,binary=true) and pass result to here
string function generateContentMD5( required any content ) {
    
	var digest = false;
    // Get our instance of the digest algorithm.
    if (NOT IsDefined("variables.messageDigest")) {
   		variables.messageDigest = createObject( "java", "java.security.MessageDigest" )
        .getInstance( javaCast( "string", "MD5" ) );
    }
    // Create the MD5 hash (as a byte array).
    digest = variables.messageDigest.digest( content );
    // Return the hashed bytes as Base64.
    return(
        binaryEncode( digest, "hex" )
    );
}


// slightly improved version of ParagraphFormat: Replaces each line break with <br> and tabs with 4 spaces
function ParagraphFormat2(str) {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	return replace(str,chr(10),"<br />","ALL");
}

	/**
	* an ASCII string to hexadecimal.
	*
	* @param str      String to convert to hex. (Required)
	* @return Returns a string.
	* @author Chris Dary (umbrae@gmail.com)
	* @version 1, May 8, 2006
	*/
	function stringToHex(str) {
	    var hex = "";
	    var i = 0;
	    for(i=1;i lte len(str);i=i+1) {
	        hex = hex & right("0" & formatBaseN(asc(mid(str,i,1)),16),2);
	    }
	    return hex;
	}

// format supplied markdown text
function markdown(textStr) {
	if (NOT StructKeyExists(this,"markdowm")) {
		this.markdown = createObject("component","textile.markdown");
		this.markdown.init();
	}

	return this.markdown.processText(arguments.textStr);
}

// make first letter of a string lower case
function camelCase(textStr) {
	 return Lcase(Left(arguments.textStr,1)) & Right(arguments.textStr,Len(arguments.textStr)-1);
}
/**
 * Capitalise first letter and replace underscors with spaces.
 */
function labelFormat(textStr) {
	arguments.textStr = Replace(arguments.textStr,"_"," ","all");
	arguments.textStr = Ucase(Left(arguments.textStr,1)) & Right(arguments.textStr,Len(arguments.textStr)-1);
	if (right(arguments.textStr,3) eq " id") {
		arguments.textStr = Left(arguments.textStr,len(arguments.textStr) - 3) & " ID";
	}
	return arguments.textStr;
}

/**
 * Replace not alpha numeric, lower case and replace underscors with spaces.
 */
function idFormat(textStr) {
	arguments.textStr = Replace(arguments.textStr,"_"," ","all");
	arguments.textStr = REReplaceNoCase(arguments.textStr, "[^a-z0-9\_]", "","ALL");
	arguments.textStr = Lcase(arguments.textStr);
	
	return arguments.textStr;
}



/**
* Sort a structure using multiple sort criteria. 
* @param  {[type]} struct  data          Struct of structs
* @param  {[type]} array   sortCriteria  Array of structs with keys: field, type(=text), direction(=asc)
* @param  {[type]} boolean dump          Pass in true of you want to dump and abort to see whats happening.
* @return {[type]}         [description]
*/

// array function structMultiSort(required struct data, required array sortCriteria, array keylist) {

// 	if (ArrayLen(sortCriteria) lt 2) throw("Don't use this for single sort criteria. Use StructSort(). Only makes sense for multiple criteria");
	
// 	// append defaults to criteria
// 	for (local.crit in arguments.sortCriteria) {
// 		structAppend(local.crit,{type="text",direction="asc"},0);
// 	}

// 	// bubble sort obviously more efficient on already sorted list
// 	if (NOT structKeyExists(arguments,"keylist")) {
// 		arguments.keyList = StructSort(arguments.data, arguments.sortCriteria[1].type, arguments.sortCriteria[1].direction, arguments.sortCriteria[1].field);
// 	}
	
// 	local.res = [];

// 	// writeDump(arguments.keylist);

// 	// Perform a bubble sort.
//        for (local.OuterIndex=1;  local.OuterIndex lt (ArrayLen(arguments.keyList)); local.OuterIndex+=1 ) {

// 		for (local.InnerIndex=1;  local.InnerIndex lte (ArrayLen(arguments.keyList) - local.OuterIndex); local.InnerIndex+=1 ) {
// 			// writeOutput("OuterIndex=#local.OuterIndex#, InnerIndex=#local.InnerIndex#<br>");
// 			local.swap = 0;
//                local.less = 0;
//                local.more = 0;
//                local.key1 = arguments.keyList[ local.InnerIndex ];
//                local.key2 = arguments.keyList[ local.InnerIndex + 1 ];
// 			for (local.crit in arguments.sortCriteria) {
// 				local.val1 = arguments.data[local.key1][local.crit.field];
// 				local.val2 = arguments.data[local.key2][local.crit.field];
// 				// writeOutput("Comparing #local.val1# to #local.val2#<br>");
// 				if (local.val1 eq local.val2) continue;
// 				switch (local.crit.type) {
// 					case "numeric": case "date":
// 						// blank always evealuates to less than a value
// 						if (local.val1 eq "") {
// 							if (local.val2 neq "") local.less = 1;
// 						}
// 						else if (local.val2 eq "") {
// 							local.more = 1;
// 						}
// 						else {
// 							local.less = local.val1 lt local.val2;
// 							local.more = local.val1 gt local.val2;
// 						}
// 						break;
// 					case "text":
// 						local.comp = compareNoCase(local.val1, local.val2);
// 						local.less = local.comp lt 0;
// 						local.more = local.comp gt 0;
// 						break;
// 				}
// 				if (local.less OR local.more) {
// 					if (local.crit.direction eq "asc") {
// 						// writeOutput("Asc: swap = #local.more#<br>");
// 						local.swap = local.more;
// 					}
// 					else {
// 						// writeOutput("Desc: swap = #local.less#<br>");
// 						local.swap = local.less;
// 					}
// 					break;
// 				}
// 			}
            
//                if (local.swap) {
//                    // Swap the two indexed objects.
//                    // writeOutput("Swapping #local.InnerIndex# with #local.InnerIndex + 1#<br>");
//                    ArraySwap(
//                        arguments.keylist,
//                        local.InnerIndex,
//                        (local.InnerIndex + 1)
//                        );

//                    // writeDump(arguments.keylist);

//                }

//            }

//        }

// 	return arguments.keylist;
// }

array function structMultiSort(required struct data, required array sortCriteria, boolean dump = false, string pk_type = "integer") {

	if (ArrayLen(sortCriteria) lt 2) throw("Don't use this for single sort criteria. Use StructSort(). Only makes sense for multiple criteria");
	if (structIsEmpty(arguments.data)) return [];

	var sql="";

	for (local.crit in arguments.sortCriteria) {
		structAppend(local.crit,{type="varchar",direction="asc"},0);
		if (local.crit.type eq "text") local.crit.type = "varchar";
		if (local.crit.type eq "numeric") local.crit.type = "Double";
		// ascending, descending -> asc,desc
		local.crit.direction = ReplaceNoCase(local.crit.direction,"ending","");
		sql = ListAppend(sql,'q.[#local.crit.field#] #local.crit.direction#');
	}

	// create list of columns and column types
	local.colList = '';
	local.typeList = '';
	for (local.crit in arguments.sortCriteria) {
		local.colList = listAppend(local.colList, local.crit.field);
		local.typeList = listAppend(local.typeList, local.crit.type);
	}
	local.colList = listAppend(local.colList, "key");
	local.typeList = listAppend(local.typeList, arguments.pk_type);

	var q = QueryNew(local.colList, local.typeList);

	// populate query data
	for (local.i in arguments.data) {
		queryAddRow(local.q, 1);
		for (local.crit in arguments.sortCriteria) {
			local.val = arguments.data[local.i][local.crit.field];
			querySetCell(q, local.crit.field, local.val);
			if( local.val eq '' ) {
				querySetCell(q, local.crit.field, javacast("null", 0));
			}
		}
		querySetCell(q, "key", local.i);
	}

	var queryService = new query(q=q); 
	queryService.setDBType('query');
		sql="SELECT * from q ORDER BY " & sql;

	if( arguments.dump ) {
		writeDump(arguments.data);
		writeDump(arguments.sortCriteria);
		writeDump(q);
		writeDump(sql);
		abort;
	}

	result = queryService.execute(sql=sql).getResult();

	var sorted = ListToArray(ValueList(result.key)); 
	
	return sorted;
}

/**
 * sort a struct on a key that might contain empty data
 * @param   required     struct        data             The data to sort
 * @param   required     string        sortType         sort type
 * @param   required     string        sortorder        asc | desc
 * @param   required     string        pathtosubelement The key to sort on
 * @param   defaultValue The value to give to any empty elements
 * @return {array}
 */
array function structSortEmpty( required struct data, required string sortType, required string sortorder, required string pathtosubelement, defaultValue ) {
	var tempData = duplicate(arguments.data);
	switch( arguments.sortType ) {
		case 'numeric':
			arguments.defaultValue = -9*10^14;
		break;
		default:
			throw('structSortEmpty called with sortType="#arguments.sortType#" without specifying defaultValue');
		break;
	}
	for ( local.key in tempData ) {
		if(NOT structKeyExists(tempData[local.key],arguments.pathtosubelement) OR tempData[local.key][arguments.pathtosubelement] eq '' ) {
			tempData[local.key][arguments.pathtosubelement] = arguments.defaultValue;
		}
	}
	return structSort(tempData, arguments.sortType, arguments.sortorder, arguments.pathtosubelement);
}

/**
 * Sorts an array of structures based on a key in the structures.
 * 
 * @param aofS 	 Array of structures. (Required)
 * @param key 	 Key to sort by. (Required)
 * @param sortOrder 	 Order to sort by, asc or desc. (Optional)
 * @param sortType 	 Text, textnocase, or numeric. (Optional)
 * @param delim 	 Delimiter used for temporary data storage. Must not exist in data. Defaults to a period. (Optional)
 * @return Returns a sorted array. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, April 4, 2013 
 */
function arrayOfStructsSort(aOfS,key){
		//by default we'll use an ascending sort
		var sortOrder = "asc";		
		//by default, we'll use a textnocase sort
		var sortType = "textnocase";
		//by default, use ascii character 30 as the delim
		var delim = ".";
		//make an array to hold the sort stuff
		var sortArray = arraynew(1);
		//make an array to return
		var returnArray = arraynew(1);
		//grab the number of elements in the array (used in the loops)
		var count = arrayLen(aOfS);
		//make a variable to use in the loop
		var ii = 1;
		//if there is a 3rd argument, set the sortOrder
		if(arraylen(arguments) GT 2)
			sortOrder = arguments[3];
		//if there is a 4th argument, set the sortType
		if(arraylen(arguments) GT 3)
			sortType = arguments[4];
		//if there is a 5th argument, set the delim
		if(arraylen(arguments) GT 4)
			delim = arguments[5];
		//loop over the array of structs, building the sortArray, while allowing for a key not to be present in all structs
		for(ii = 1; ii lte count; ii = ii + 1)
			sortArray[ii] = (structKeyExists(aOfS[ii],key) ? aOfS[ii][key] : ' ') & delim & ii;
		//now sort the array
		arraySort(sortArray,sortType,sortOrder);
		//now build the return array
		for(ii = 1; ii lte count; ii = ii + 1)
			returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];
		//return the array
		return returnArray;
}
/**
 * Convert a struct to a plain text string. Use to dump structs when writing text e.g. css when dump won't work
 * @param  Struct sData       Struct to dump
 * @return String        Plain text sting
 */
public string function structToString(Struct sData) {
	var max = 5;
	var key = false;
	var retVal = "";

	for (key in arguments.sData) {
		if (Len(key) gt max) max = len(key);
	}
	max += 2;
	for (key in arguments.sData) {
		retVal &= LJustify(key,max) & arguments.sData[key] & chr(13) & chr(10);
	}
	return retVal;

}
</cfscript>

<cffunction name="FormatText"  output="No" returntype="string" hint="Format plain text for output onto
	page. Replaces returns with <code>&lt;br&gt;</code>. Returns the formatted string.">

	<cfargument name="copy" hint="Copy to format" type="string">
	
	<cfset var sResults = false>
	<cfset var i = false>
	<cfset var preserveTags = ArrayNew(1)>
	<cfset var tagCounter = 1>
	<!--- preserve some formatting here - take out chunks and store them in
	preserveTags[]. Later on we replace all these --->
	
	<!--- preserve formatting within <HTML></HTML> tags --->
	<cfset sResults = fnFindStrings(arguments.copy,"<html>.*?</html>")>
	<cfloop from="1" to="#ArrayLen(sResults)#" index="i">
		<cfset preserveTags[tagCounter] = ReReplaceNoCase(sResults[i],"</?html>","","all")>
		<cfset arguments.copy = Replace(arguments.copy,sResults[i],"[tagReplace#tagCounter#]")>
		<cfset tagCounter += 1>
	</cfloop>
	
	<!--- preserve formatting within <script></script> tags and keep tags --->
	<cfset sResults = fnFindStrings(arguments.copy,"<script.*?>.*?</script>")>
	<cfloop from="1" to="#ArrayLen(sResults)#" index="i">
		<cfset preserveTags[tagCounter] = sResults[i]>
		<cfset arguments.copy = Replace(arguments.copy,sResults[i],"[tagReplace#tagCounter#]")>
		<cfset tagCounter += 1>
	</cfloop>
	
	<!--- format table. Split rows at cr and cells at tabs. You must ensure equals columns - use
	single spaces --->
	<cfset sResults = fnFindStrings(arguments.copy,"<table.*?>.*?</table>")>
	<cfloop from="1" to="#ArrayLen(sResults)#" index="i">
		<cfset arguments.copy = Replace(arguments.copy,sResults[i],fnParseTable(sResults[i]))>
	</cfloop>


	<!--- format pricelist. 

	Item ...............Price
	Optional description

	Item ...............Price
	Optional description		
	--->
	<cfset sResults = fnFindStrings(arguments.copy,"<pricelist.*?>.*?</pricelist>")>
	<cfloop from="1" to="#ArrayLen(sResults)#" index="i">
		<cfset arguments.copy = Replace(arguments.copy,sResults[i],fnParsePriceList(sResults[i]))>
	</cfloop>
	
	<cfset arguments.copy = ReReplaceNoCase(Trim(arguments.copy), "\s*<(p|h\d+|ol|li|ul)>", "<\1>", "all")>
	<cfset arguments.copy = ReReplaceNoCase(Trim(arguments.copy), "\s*</(p|h\d+|ol|li|ul)>\s+", "</\1>{cr}", "all")>
	
	<cfset arguments.copy = Replace(arguments.copy, chr(13) & chr(10), chr(13), "all")>
	<cfset arguments.copy = Replace(arguments.copy, chr(10), chr(13), "all")>
	<cfset arguments.copy = Replace(arguments.copy, chr(13), "<br>" & chr(13) & chr(10) , "all")>
	
	<!--- put back in the preserved tags --->
	<cfloop from ="1" to="#ArrayLen(preserveTags)#" index="i">
		<cfset arguments.copy = Replace(arguments.copy,"[tagReplace#i#]",preserveTags[i])>
	</cfloop>
	
	
	<cfset arguments.copy = Replace(arguments.copy, "{cr}", chr(13) & chr(10), "all")>
	
	<cfreturn arguments.copy>

</cffunction>

<cffunction name="fnFindStrings" hint="Uses the results of an REFind with return sub expressions on to create an array of 
	the matched patterns. This can then be used to substitute theses patterns one by one">
	<cfargument name="text">
	<cfargument name="pattern">
	
	<cfset var results = ArrayNew(1)>
	<cfset var local = StructNew()>
	<cfset local.start = 1>
	
	<cfloop condition="local.start lte Len(arguments.text)">

		<cfset local.searchresults = REFindNoCase(arguments.pattern,arguments.text,local.start,1)>
		
		<cfif local.searchresults.len[1] eq 0>
			<cfreturn results>
		</cfif>
		
		<cfset local.temp = Mid(arguments.text,local.searchresults.pos[1],local.searchresults.len[1])>
		<cfset ArrayAppend(results,local.temp)>
		<cfset local.start = local.searchresults.pos[1] + local.searchresults.len[1] - 1>
		
		<!---	
		<cfloop index="local.i" from="1" to="#ArrayLen(local.searchresults.len)#">
			
		</cfloop>
		--->

	</cfloop>
	
	<cfreturn results>
	
</cffunction>


<cffunction name="fnParseTable">
	<cfargument name="content">
	
	<cfset var row = "">
	<cfset var rowNum = 0>
	<cfset var headerRow = "">
	<cfset var column = "">
	<cfset var colNum = 1>
	<cfset var colClass = false>
	<cfset var rowContent = "">
	<cfset var tableContent = "">
	<cfset var cellTag = "td">
	<cfset var oddEven = "odd">
	<cfset var temp = "">
	<cfset var local = {}>
	
	<cfset fnLog(text="#arguments.content#",category="tables")>
	
	<!--- get the table arguments --->
	<cfset local.tagMatch = REMatchNoCase("(\[{1,2}|<)table([^>\]]*)/?(\]{1,2}|>)",arguments.content)>
	<cfset local.argVals = fnParseTagAttributes(local.tagMatch[1])>
	
	<!--- also remove table tag in case it runs onto multiple lines --->
	<cfset arguments.content = Replace(arguments.content,local.tagMatch[1],"")>
	<cfset arguments.content = REReplaceNoCase(arguments.content,"</table>","")>
		
			
	<!--- header - First row is header --->
	<cfif NOT StructKeyExists(local.argVals,"header") OR NOT IsBoolean(local.argVals.header)>
		<cfset local.argVals.header = 0>
	</cfif>
	<!--- footer - Repeat header as footer--->
	<cfif NOT StructKeyExists(local.argVals,"footer") OR NOT IsBoolean(local.argVals.footer) OR NOT local.argVals.header>
		<cfset local.argVals.footer = 0>
	</cfif>
	<!--- firstcol - Apply hightlighting to first column --->
	<cfif NOT StructKeyExists(local.argVals,"firstcol") OR NOT IsBoolean(local.argVals.firstcol)>
		<cfset local.argVals.firstcol = 0>
	</cfif>
	<!--- firstcol_class - Class to apply to first column if firstcol --->
	<cfif NOT StructKeyExists(local.argVals,"firstcol_class")>
		<cfset local.argVals.firstcol_class = "col_hilite">
	</cfif>
	
	<cfset local.tbleStr = "">
	<cfloop item="local.attr" collection="#local.argVals#">
		<cfswitch expression="#local.attr#">
			<cfcase value="class,cellspacing,cellpadding,id,summary,width,frame,rules,dir,lang,style,title,xml:lang">
				<cfset local.tbleStr &= " #local.attr#=""#local.argVals[local.attr]#""">
			</cfcase>
		</cfswitch>
	</cfloop>
	
	<cfset tableContent &="<table#local.tbleStr#>{cr}">
	
	<!--- 0 = header row --->
	<cfif NOT local.argVals.header>
		<cfset rowNum = 1>				
	</cfif>				
	
	<!--- colgroup,thead,tfoot,caption,tr can al be inserted into the flow. head and foot are a bit of a legacy,
	as these acn now be controlled by arguments. To process them correctly, we convert them to a single line by replacing
	the returns with {cr} and then later we ignore the whole line --->
	<cfloop index="local.tag" list="colgroup,thead,tfoot,tbody,caption,tr">
		<cfset local.sResults = fnFindStrings(arguments.content,"<#local.tag#.*?>.*?</#local.tag#>")>
		<cfloop from="1" to="#ArrayLen(local.sResults)#" index="local.i">
			<cfset arguments.content = Replace(arguments.content,local.sResults[local.i],fnStripReturns(local.sResults[local.i]))>
		</cfloop>
	</cfloop>
					
	<cfloop index="row" list="#arguments.content#" delimiters="#chr(13)##chr(10)#">
		
		<cfset fnLog(text="Row: #HTMLEditFormat(row)#",category="tables")>
		
		<cfif REFindNoCase("</?table", row)>
			<!---cfcontinue--->			
		<cfelseif FindNoCase("<colgroup", row) OR FindNoCase("<thead", row) OR FindNoCase("<tfoot", row) OR FindNoCase("<caption", row) OR FindNoCase("<tbody", row) OR FindNoCase("<tr", row)>
			<cfset tableContent = tableContent & fnStripReturns(row) & "{cr}">
		<cfelse>
			<cfif rowNum mod 2>
				<cfset oddEven = "odd">
			<cfelse>
				<cfset oddEven = "even">
			</cfif>
			
			<cfif local.argVals.header and rowNum eq 0>
				<cfset cellTag = "th">
				<cfset rowContent = "<tr>">
			<cfelse>
				<cfset cellTag = "td">
				<cfset rowContent = "<tr class=""row#rowNum# #oddEven#"">">
			</cfif>
			
			<cfset colNum = 1>
			<cfloop index="column" list="#row#" delimiters="#chr(9)#">
				<!--- blank cols must have nbsp --->
				<cfif column eq " ">
					<cfset temp =  "&nbsp;">
				<cfelse>
					<cfset temp =  Trim(column)>
				</cfif>
				<!--- apply special class to firstcol? --->
				<cfif local.argVals.firstcol and colNum eq 1>
					<cfset colClass = " class=""#local.argVals.firstcol_class#""">
				<cfelse>
					<cfset colClass = "">
				</cfif>
				<cfset rowContent &=  "<#cellTag##colClass#>" & fnParseReturns(temp) & "</#cellTag#>">
				<cfset colNum += 1>
			</cfloop>
			<cfset rowContent = rowContent & "</tr>{cr}">
			
			<cfif rowNum eq 0 AND local.argVals.header>
				<!--- store header row to repeat as footer--->
				<cfif local.argVals.footer>
					<cfset headerRow = rowContent>
				</cfif>
				<cfset rowContent = "<thead>{cr}" & rowContent & "</thead>{cr}" >
			</cfif>
			
			<cfset rowNum += 1>
			<cfset tableContent &= rowContent>
			
		</cfif>
		
	</cfloop>
	
	<cfif local.argVals.footer>
		<cfset tableContent &= "<tfoot>{cr}" & headerRow & "</tfoot>{cr}" >
	</cfif>
	
	<cfset tableContent &="</table>{cr}">
	
	
	<cfset tableContent = Trim(fnStripReturns(tableContent))>
	
	<cfreturn tableContent>
	
</cffunction>

<cffunction name="fnParsePriceList" output="false">
	<cfargument name="content">
	
	<cfset var row = "">
	<cfset var rowNum = 0>
	<cfset var headerRow = "">
	<cfset var column = "">
	<cfset var colNum = 1>
	<cfset var colClass = false>
	<cfset var rowContent = "">
	<cfset var tableContent = "">
	<cfset var cellTag = "td">
	<cfset var oddEven = "odd">
	<cfset var temp = "">
	<cfset var local = {}>
	
	<cfset fnLog(text="#arguments.content#",category="pricelist")>
	
	<!--- get the table arguments --->
	<cfset local.tagMatch = REMatchNoCase("(\[{1,2}|<)[pricelist]([^>\]]*)/?(\]{1,2}|>)",arguments.content)>
	<cfset local.argVals = fnParseTagAttributes(local.tagMatch[1])>
	
	<!--- also remove pricelist tag in case it runs onto multiple lines --->
	<cfset arguments.content = Replace(arguments.content,local.tagMatch[1],"")>
	<cfset arguments.content = Trim(REReplaceNoCase(arguments.content,"</pricelist>",""))>

	<cfset local.attrStr = "">
	<cfset local.class = "pricelist">
	<cfloop item="local.attr" collection="#local.argVals#">
		<cfswitch expression="#local.attr#">
			<cfcase value="title">
				<cfset local.attrStr &= " #local.attr#=""#local.argVals[local.attr]#""">
			</cfcase>
			<cfcase value="class">
				<cfset local.class = ListAppend(local.class,local.argVals[local.attr]," ")>
			</cfcase>
		</cfswitch>
	</cfloop>
	
	<cfset tableContent &="<div class='#local.class#'#local.attrStr#>{cr}">
		
	
	<!--- split on double breaks only --->
	<cfset arguments.content = Replace(arguments.content,chr(13) & chr(10),chr(13),"all")>
	<cfset arguments.content = Replace(arguments.content,chr(10),chr(13),"all")>
	<cfset arguments.content = ReReplace(arguments.content,"\r\s*?\r",chr(13) & chr(13),"all")>
	<cfset arguments.content = Replace(arguments.content,chr(13) & chr(13),"&5$32","all")>
	<cfset arguments.content = Replace(arguments.content,chr(13),"$%$@@qW","all")>
	<cfset arguments.content = Replace(arguments.content,"&5$32",chr(13) & chr(13),"all")>
	
	<cfset local.listOpen = 0>
	<cfloop index="row" list="#arguments.content#" delimiters="#chr(13)#">
		
		<!--- see above, possible single return for description field --->
		<cfset local.info = Replace(row,"$%$@@qW",chr(13),"all")>
		<cfset fnLog(text="Row: #HTMLEditFormat(local.info)#",category="pricelist")>
		
		<cfif ListLen(local.info,chr(13)) gt 1>
			<cfset local.description = ListRest(local.info,chr(13))>
			<cfset local.info = ListFirst(local.info,chr(13))>
			<cfset fnLog(text="Has description #local.description#",category="pricelist")>
		<cfelse>
			<cfset local.description = "">
		</cfif>

		<!--- if it doesn't have a tab or some ...... it's section header --->
		<cfif NOT ListLen( local.info, ".#chr(9)#") gt 1>
			<cfif local.listOpen>
				<cfset tableContent &= "</ul>{cr}">
			</cfif>
			<cfset local.listOpen = 0>
			<cfset tableContent &= "<h4>#local.info#</h4>{cr}">
			<cfif local.description neq "">
				<cfset tableContent &= "<p class='description sectiondesc'>" & local.description & "</p>{cr}">
			</cfif>
		<cfelse>
			<cfif not local.listOpen>
				<cfset tableContent &= "<ul class='pricelist'>">
				<cfset local.listOpen = 1>
			</cfif>
			<cfset local.item = ListFirst(local.info,".#chr(9)#")>
			<cfset local.price = ListLast(local.info,".#chr(9)#")>
			<cfset tableContent &= "  <li>{cr}    <h5><span>" & local.item & "</span></h5><span class='price'>" & local.price & "</span>{cr}">
			<cfif local.description neq "">
				<cfset tableContent &= "    <p class='description itemdesc'>" & local.description & "</p>{cr}">
			</cfif>
			<cfset tableContent &= "  </li>{cr}">
		</cfif>

	</cfloop>

	<cfif local.listOpen>
		<cfset tableContent &= "</ul>{cr}">
	</cfif>
	
	<cfset tableContent &="</div>{cr}">
	
	
	<cfset tableContent = Trim(fnStripReturns(tableContent))>
	
	<cfreturn tableContent>
	
</cffunction>


<cffunction name="fnParseReturns">
	<cfargument name="content">
	
	<cfreturn ReplaceList(arguments.content,"#chr(13)#,#chr(10)#","{cr},")>
	
</cffunction>

<cffunction name="fnStripReturns">
	<cfargument name="content">
	
	<cfreturn ReplaceList(arguments.content,"#chr(13)#,#chr(10)#"," ,")>
	
</cffunction>


<cffunction name="fnJSDebug" output="No" returntype="string" hint="Takes the JS string to output and tests whether debugging is turned on before returning it.">
	
	<cfargument name="jsMessage" required="No" default="">
	<cfargument name="type" required="No" default="debug" hint="Firebug console output type.">
	
	<cfset var local = StructNew()>
	
	<cfset local.returnString = "">
	
	<cfif IsDebugMode()>
		<cfset local.returnString = "if (('console' in window) && ('#arguments.type#' in console)){console.#arguments.type#(#arguments.jsMessage#);}#chr(13)##chr(10)#">
	</cfif>
	
	<cfreturn local.returnString>
			
</cffunction>

<cffunction name="fnReplaceLineBreaksReturns" hint="Replace all carriage returns with line breaks">
	<cfargument name="copy">
	
	<cfset arguments.copy = Replace(arguments.copy, chr(13) & chr(10), chr(13), "all")>
	<cfset arguments.copy = Replace(arguments.copy, chr(10), chr(13), "all")>
	<cfset arguments.copy = Replace(arguments.copy, chr(13), "<br>" & chr(13) & chr(10) , "all")>
	
	<cfreturn arguments.copy>
	
</cffunction>

<cffunction name="xml2Data" hint="Parse XML into a Struct array of structs" description="An improvement on xml2struct which recognises whether a node needs to be an array. This allows for single records or multiple records without worrying about which is which. The results will be an array or a struct. Sub records within the data are similarly coped with so there's no need to go back and convert structs keyed by row number into arrays.">
		
	<cfargument name="xmlData" required="yes" hint="Either XML as produced by parseXML or else an array of XML nodes (the latter should only be used when recursing)">
	<cfargument name="addOrder"  required="false" default="0" hint="Add sort_order field to nodes to preserve order">
	<cfset var retData = false>
	<cfset var root = false>
	
	<cfset var root = arguments.xmlData.xmlRoot>

	<cfset var retData = parseXMLNode(root,arguments.addOrder)>
	
	<cfreturn retData>

</cffunction>

<cffunction name="parseXMLNode" hint="Parse an XML node into a struct or array. helper function for xml2Data. " access="public" returntype="any">
		
	<cfargument name="xmlElement" required="yes" hint="Either XML as produced by parseXML or else an array of XML nodes (the latter should only be used when recursing)">
	<cfargument name="addOrder" required="false" default="0" hint="Add sort_order field to nodes to preserve order">

	<cfset var retVal = {}>
	<cfset var child = false>
	

	<cfif isArrayNode(arguments.xmlElement)>
		<cfset retVal = []>
		<cfloop index="child" array="#arguments.xmlElement.xmlChildren#">
			<cfset ArrayAppend(retVal,parseXMLNode(child,arguments.addOrder))>
		</cfloop>		
	<cfelse>
		<cfset retVal = {}>
		<cfif arguments.addOrder>
			<cfset var order = 0>
		</cfif>
		<cfloop index="child" array="#arguments.xmlElement.xmlChildren#">
			
			<cfif Trim(child.xmlText) neq "" AND  ArrayLen(child.xmlChildren) gte 1>
				<!---assume mixed node is html--->
				<cfset local.text = reReplace(ToString(child),"([\n\r])\t+","\1","all")>
				<cfset local.text = reReplace(local.text,"\<\?xml.*?\>","")>
				<cfset local.text = reReplace(local.text,"\<\/?#child.XmlName#\>","","all")>
				<cfset addDataToNode(retVal,child.XmlName,local.text)>
			<cfelseif ArrayLen(child.xmlChildren) gte 1 OR NOT structIsEmpty(child.XmlAttributes)>
				<cfset local.data = parseXMLNode(child,arguments.addOrder)>
				<cfif IsStruct(local.data) AND arguments.addOrder>
					<cfset local.data["sort_order"] = order>
					<cfset order += 1>
				</cfif>
				<cfset addDataToNode(retVal,child.XmlName,local.data)>
			<cfelse>
				<cfset addDataToNode(retVal,child.XmlName,reReplace(child.xmlText,"([\n\r])\t+","\1","all"))>
			</cfif>	
		</cfloop>
		
		<!--- only append attribute values now. --->
		<cfset local.attrVals = this.xmlAttributes2Struct(arguments.xmlElement.XmlAttributes)>
		<cfset StructAppend(retVal,local.attrVals,false)>

		<!--- allow use of arbitrary text content as "value" attribute in mixed nodes 
		if value is already defined as attribute, use textValue, unless tag is <option> in which case use display
		--->
		<cfif NOT arrayLen(arguments.xmlElement.xmlChildren) AND Trim(arguments.xmlElement.xmlText) neq "" AND structCount(retVal)>
			<cfset local.tagName = "value">
			<cfif structKeyExists(retVal,"value")>
				<cfif arguments.xmlElement.XmlName eq "option">
					<cfset local.tagName = "display">
				<cfelse>
					<cfset local.tagName = "textValue">
				</cfif>
			</cfif>

			<cfset retVal[local.tagName] = reReplace(arguments.xmlElement.xmlText,"([\n\r])\t+","\1","all")>
		</cfif>

	</cfif>

	<cfreturn retVal>

</cffunction>

<cffunction name="addDataToNode" returntype="void" hint="helper function for parseXMLNode. Adds data to a struct. If the key already exists, appends to an array" access="private">
	
	<cfargument name="sNode" required="true">
	<cfargument name="key" required="true">
	<cfargument name="sData" required="true">

	<cfif NOT structKeyExists(arguments.sNode,arguments.key)>
		<!--- Guess data type. --->
		<cfif isNumeric(arguments.sData)>
			<cfset arguments.sNode[arguments.key] = Val(arguments.sData)>
		<cfelseif isBoolean(arguments.sData)>
			<cfset arguments.sNode[arguments.key] = NOT NOT arguments.sData>
		<cfelse>
			<cfset arguments.sNode[arguments.key]= arguments.sData>
		</cfif>
	<cfelse>
		<cfif NOT isArray(arguments.sNode[arguments.key])>
			<cfset local.tmpHolder = Duplicate(arguments.sNode[arguments.key])>
			<cfset arguments.sNode[arguments.key] = []>
			<cfset arrayAppend(arguments.sNode[arguments.key],local.tmpHolder)>
		</cfif>
		<cfset arrayAppend(arguments.sNode[arguments.key],arguments.sData)>
	</cfif>

</cffunction>

<cffunction name="isArrayNode" returntype="boolean" hint="helper function for parseXMLNode. Checks whether node should be an array of nodes" access="private">
	<!--- if all the children have the same name, then this is an array --->
	<cfargument name="xmlElement" required="yes">
	
	<cfset var isArray = 0>
	<cfset var childNames = {}>

	<cfif structIsEmpty(arguments.xmlElement.XMLAttributes) AND arrayLen(arguments.xmlElement.xmlChildren) gt 1>
		<cfloop index="local.child" array="#arguments.xmlElement.xmlChildren#">
			<cfset childNames[local.child.XMLName] = 1>
		</cfloop>
		<cfif structCount(childNames) eq 1>
			<cfset isArray = 1>
		</cfif>
	</cfif>

	<cfreturn isArray>

</cffunction>

<cfscript>
/**
 * Display a help button for use with doClikHelp() in clikUtils js
 *
 * @ID      Unique ID
 * @content Text of help item
 * @title   Title of help dialogue
 */
public string function helpButton(required string  ID, required  string content, string title = "Help") {

	var retVal = "<span id='#arguments.ID#_helpicon' class='helpicon noprint' title='#arguments.title#'>";

	retVal &= "<span class='icon-stack'>";
   	retVal &= "<i class='icon-stack-base icon-sign-blank noprint'></i>";
   	retVal &= "<i class='icon-question icon-light noprint'></i>";
   	retVal &= "</span>";
   	retVal &= "<div class='clikHelpTitle'>#arguments.title#</div>";
   	retVal &= "<div class='clikHelpContent'>#arguments.content#</div>";
   	retVal &= "</span>";

	return  retVal;

}
	
</cfscript>
	<cffunction name="getRemoteFile" output="no" hint="Save a remote file to the specified directory">
		
		<cfargument name="url" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		
		<cfhttp url="#arguments.url#" path="#arguments.path#">
		
	</cffunction>

	

	<cffunction name="EncodeURL" output="No" returntype="string" hint="Encode certain characters for the Google sitemaps">
		
		<cfargument name="in_url" required="Yes">
		
		<cfset var characters_to_replace = "&,',"",<,>">
		<cfset var replacement_characters = "&amp;,&apos;,&quot;,&lt;,&gt;">
		
		<cfset var out_url = ReplaceList(arguments.in_url, characters_to_replace, replacement_characters)>
		
		<cfreturn out_url>
	</cffunction>

	<cffunction name="W3cDateTimeFormat" output="No" returntype="string" hint="format a date time in w3c format">

		<cfargument name="dateObj">
		
		<cfset var timeZone = GetTimeZoneInfo()>
		<cfset var retVar = DateFormat(arguments.dateObj,"yyyy-mm-dd")>
		<cfset retVar = retVar & "T" & TimeFormat(arguments.dateObj,"HH:mm:ss")>
		<cfset retVar = retVar & NumberFormat(timeZone.utcHourOffset,"+09") & ":00">
		
		<cfreturn retVar>
	
	</cffunction>

	<cffunction name="xmlAttributes2Struct">
		<cfargument name="xmlAttributes">

		<cfset var retStr = {}>

		<cfloop collection="#arguments.xmlAttributes#" item="local.key">
			<!--- Guess data type. --->
			<cfset local.value = arguments.xmlAttributes[local.key]>
			<cfif isNumeric(local.value)>
				<cfset local.value = Val(local.value)>
			<cfelseif isBoolean(local.value)>
				<cfset local.value = NOT NOT local.value>
			</cfif>

			<cfset retStr[local.key] = local.value>
		</cfloop>

		<cfreturn retStr>
	</cffunction>

	<cffunction name="fnFieldReplace" hint="Replace fields in format {$filename} with values from struct" output="no" returntype="string">
		<cfargument name="text" type="string" required="yes">
		<cfargument name="fields" type="struct" required="yes">
		
		<cfset var retStr = arguments.text>
		<cfset var sfield = false>
		<cfset var matches = false>
		<cfset var match = false>
		
		
		<cfset matches = reMatchNoCase("\{\$*.+?\}",arguments.text)>
		<cfif arrayLen(matches)>
			<cfloop index="match" array="#matches#">
				<cfset sfield = ListFirst(match,"{$}")>
				<cfif StructKeyExists(arguments.fields,sfield)>
					<cfset retStr = REReplaceNoCase(retStr, "\{\$*#sfield#\}", arguments.fields[sfield], "all")>
				</cfif>
			</cfloop>			
		</cfif>
		
		<cfreturn retStr>
		
	</cffunction>


<cffunction name="parseCSV" output="true" returntype="array" hint="Parse CSV data into array of arrays. NB Doesn't really work, field delims sort of hardwired as """>
	<cfargument name="data" type="string" required="true">
	<cfargument name="rowdelim" required="false" default="#chr(10)##chr(9)#">
	<cfargument name="fielddelim" required="false" default="""">

	<cfscript>
	var retval = [];
	var rows = listToArray(arguments.data,rowdelim);
	var nextDelim = false;
	var patt = ",(?=([^\""]*\""[^\""]*\"")*[^\""]*$)";
	var rowArr = false;
	var jArray = false;
	var fieldVal = false;

	var hasDelims = arguments.fieldDelim neq "";
	for (var row in rows) {
		jArray =  row.ToString().Split(patt);
		// jArray = CreateObject(
		// "java",
		// "java.util.Arrays"
		// ).AsList(
		//     ToString(row).Split(patt)
		//     );
		rowArr = [];
		
		for (var field in jArray) {
				fieldVal =  field;
				if (hasDelims) {
					if (listFind(arguments.fieldDelim, Left(fieldVal,1))) {
						fieldVal = listFirst(field,arguments.fieldDelim);
					}
				}
				ArrayAppend(rowArr,fieldVal);
		}
		ArrayAppend(retval,rowArr);
	}

	return retVal;
	</cfscript>

</cffunction>

</cfcomponent>