<!---

# Image Grid testing page

Test styling for image grids. Also contains all our work on the settings form.

Currently working as a proof of concept albeit with a bit of a lash up.

## WIP

Now sort of working for dynamic updates. The javaScript doesn't reload when you change layout mode, so I'm working on that.



TODO: 

1. Somehow redo javascript for e.g. masonry once everything has reloaded. This might have to wait pending a general review of how we do this on resize etc.
2. Redo component as a singleton and persist the objects etc.

## Status

Now working in standard fashion.

## History

2023-05-15 THP Merged back in the form stuff. This has broken the idea of a "test". Need to separate out the selection of a test and the settings form.
2023-05-01  THP   Wasn't using the cs obj (??).
2023-04-15  THP   Updated to use the grid styling in settingsObj 
2022-03-05  THP   Created

--->


<cfscript>
param name="request.rc.action" default='index';
param name="request.rc.test" default='auto';
param name="request.rc.medium" default='main';

settings = new settings(testname=request.rc.test);

pageData = settings.pageData();
form_html = settings.settingsForm();

tests = [
	{id="auto",title="Auto grid"},
	{id="fixedwidth",title="Columns have set width"},
	{id="fixedcols",title="Fixed number of columns"},
	{id="setcols",title="Specified columns"},
	{id="heights",title="Limit the height of images"},
	{id="captiontop",title="Caption at the top plus some frame styling"},
	{id="overlay",title="Caption overlay"},
	{id="masonry",title="Masonry"},
	{id="carousel",title="Carousel"}
];

</cfscript>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/flickity.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
		<link rel="stylesheet" type="text/css" href="_styles/settingsPanel.css">
		<link rel="stylesheet" href="/_assets/css/jquery.mCustomScrollbar.min.css">

		<style id="main">
			body {
				background-color: #f3f3f3;
				padding:20px;
			}
			
		</style>
		<style id="css">
			<cfoutput>#settings.css()#</cfoutput>
		</style>
		
		
	</head>

	<body class="body">
		
		<div>			
			<cfoutput>#pageData.html#</cfoutput>
		
		</div>
		<div>
			<form action="imagegrid.cfm">

				<h2>Test mode</h2>
				<select name="test">
					<cfloop index="test" array="#tests#">
						<cfset selected =request.rc.test eq test.id ? "selected" : "">
						<cfoutput>
						<option #selected# value="#test.id#">#test.title#</option>
						</cfoutput>
					</cfloop>
				</select>

				<label></label>				
				<div class="button"><input type="submit" value="Update"></div>
			</form>
		</div>

		<div id="settings_panel" class="settings_panel modal">

			<form id="settingsForm" action="imagegrid.cfm">
				
				<div class="formInner">
					<div class="title">
						<h2>Settings</h2>
					</div>
					<div class="wrap">
					<cfoutput>#form_html#</cfoutput>
					</div>
					<div class="submit">
						<label></label>				
						<div class="button"><input type="submit" value="Update"></div>
					</div>
				</div>
			</form>
		</div>

		<div id="settings_panel_open"><div class="button auto"><a href="#settings_panel.open">Settings</a></div></div>

		<script src="/_assets/js/jquery-3.4.1.js"></script>
		<script src="/_assets/js/imagesloaded.pkgd.js"></script>
		<script src="/_assets/js/isotope.pkgd.min.js"></script>
		<script src="/_assets/js/masonry-horizontal.js"></script>
		<script src="/_assets/js/flickity.pkgd.min.js"></script>
		<script src="/_assets/js/jquery.modal.js"></script>
		<script src="/_assets/js/jquery.autoButton.js"></script>
		<script src="/_assets/js/jquery.serializeData.js"></script>
		<script src="/_assets/js/clik_settings.js"></script>
		<script src="/_assets/js/getSettings.js"></script>
		<script src="/_assets/js/photogrid.js"></script>
		<script src="/_assets/js/jquery.mCustomScrollbar.min.js" type="text/javascript" charset="utf-8"></script>

		<script>
		
		$( document ).ready( function() {
			
			<cfoutput>
			#pageData.pagecontent.onready#
			</cfoutput>

			$("#settings_panel").modal({
				draggable:true,
				modal:false
			});
			$('.button').button();

			$("#settings_panel .wrap").mCustomScrollbar();

			// attach handler to form's submit event 
			$('#settingsForm').submit(function() { 
			    // submit the form 
			    var data = $(this).serializeData(); 
			    console.log(data); 

			    $.ajax({
			    	url:"settings_api.cfc?method=css",
			    	data: {"settings": JSON.stringify(data)},
			    	method: "post"
			    }).done(function(e) {
			    	$('#css').html(e.css);
			    	console.log($('#css').html()); 
			    	console.log("we have updated");
			    	$testgrid.data("photoGrid").reload();
			    });

			     
			    return false; 
			});

		});	
		</script>
	</body>
	
</html>

