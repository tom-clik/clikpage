<!---

Different ideas for tabs. Working nicely.

--->

<!DOCTYPE html>
<html>
<head>
	<title>Tabs test</title>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/title.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/fonts/fonts_local.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/panels.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/schemes/panels-schemes.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/tabs.css">

	<meta charset="UTF-8">
	<style>
		body {
			--title-font:font-family: 'Open Sans';
		}
		img {
			max-width: 100%;
		}
		.cs-tabs {
/*			background-color: #9d9d9d;*/
			margin:20px 0;
		}
		
		.container {
			margin:40px;
			--tab-font-weight:300;
			--tab-font-size:.8em;
			--tab-border-radius:0;
		}
		
		.cs-tabs .item {
			border-top: 1px solid #9c9c9c;
			--tab-border-color: #9c9c9c;
			--tab-border-width: 1px 0 0 0;
			padding:6px;
		}
		.cs-tabs .title {
			--tab-border-color: #9c9c9c;
		}

		.cs-tabs .title:hover {
			--tab-background: #9c9c9c;
		}

		#test {
			--tab-border-radius:4px;
			background-color: transparent;
			--fixedheight:false;
		}

		#test.cs-tabs .item {
			border: 1px solid #9c9c9c;
		}

		#test {
			--vertical:true;
			--fixedheight:true;
		}
		
		@media screen and (min-width:1200px) {
			
			#test {
				--vertical:false;
				--fixedheight:false;
			}

		}

		@media screen and (max-width:800px) {
			#test {
				--vertical:false;
				--accordian:true;
				--allowClosed:true;
			}

		}
	</style>
</head>
<body>

<div class="cs-title">
Tab/Accordion/info panel Testing
</div>

<cfoutput>
	#getTabs(id="test",count=6)#

	<a id="resize">Resize</a>
</cfoutput>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.animateAuto.js"></script>	
<script src="/_assets/js/jquery.tabs.js"></script>	
<script src="/_assets/js/jquery.throttledresize.js"></script>
<script src="/_assets/js/clik_common.js"></script>
<script src="/_assets/js/clik_onready.js"></script>

<script>
	// nothing to do with the tabs - just adds text to tab
$( document ).ready(function() {
	$("#resize").on("click",function(e) {
		e.stopPropagation;
		text = $("#test_tab1 .item").html();
		$("#test_tab1 .item").html(text + text + text);
		console.log("resize");
		$(".cs-tabs").trigger("resize");
	 });
});
</script>
</body>
</html>

<cfscript>
function getTabs(required string id, numeric count=4) {

	var ret="";
	
	ret &= "<div class='container cs-tabs' id='#arguments.id#'>\n";
	
	for (var i = 1; i lte arguments.count; i++) {
		local.open = false and i eq 2 ? " state_open": "";
		ret &= "	<div class='#local.open#' id='#arguments.id#_tab#i#'>\n";
		ret &= "		<h3 class='title'>tab #i#</h3>\n";
		ret &= "		<div class='item'>\n";
		for (var p=1 ; p lte i; p++) {
			ret &= "			<p>Tab #i# Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod\n";
			ret &= "			tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,\n";
			ret &= "			quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo\n";
			ret &= "			consequat.</p>\n";
		}
		ret &= "		</div>\n";
		ret &= "	</div>\n";
	}
	ret &= "</div>";

	return Replace(ret,"\n",NewLine(1),"all");

}


</cfscript>