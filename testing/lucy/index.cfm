<cfscript>
condition = "freezing";
getCondition();

if (condition eq "warm") {
	writeOutput("I'm hot");
}
else if (condition eq "cold") {
	writeOutput("I'm chilly");
}
else {
	writeOutput("I'm " & condition);
}

function getCondition() {
	condition = "Very chilly";
}

</cfscript>