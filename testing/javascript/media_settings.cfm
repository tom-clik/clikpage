<cfscript>
/*
Testing media settings

see _notes/Medium based JavaScript options.md

## Notes

Triggers a displayMedia() function when we transition between media queries.

This just queries the element for some random custom prperties and displays their values.

The plan is to use a similar script to trigger a custom window event that causes elements to rebuild.

*/
settingsObj = new clikpage.settings.settings();
styles = settingsObj.loadStyleSettings(ExpandPath("../styles/testStyles.xml"));


</cfscript>


<!DOCTYPE html>
<html>
<head>
	<title>Scrollbar test</title>
	<link rel="stylesheet" href="/_assets/css/reset.css">
	
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<style>
		#title {
			--title:my test;
			--test:true;
			--other:64px;

		}
		@media only screen and (min-width: 1200px) {
			#title {
				--title:my test max;
				--other:84px;
			}
		}

		@media only screen and (max-width: 800px) {
			#title {
				--title:my test mid;
				--test:false;
			}
		}

		@media only screen and (max-width: 600px) {
			#title {
				--title:my test mobile;
			}
		}
	</style>
</head>
<body>

<div id="ubercontainer">
	<div id="title">
	</div>
	<div id="settings">
	</div>
</div>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.throttledresize.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript">

$(document).ready(function() {
	$title = $("#title");
	$settings = $("#settings");
	$window = $(window);
	medium = "undef";
	<cfoutput>
	media = #serializeJSON(styles.media)# ;
	</cfoutput>
	
	getMedia();

	$window.on("throttledresize",function() {
		getMedia();
	});

	function displayMedia(name) {
		console.time("Getting properties");
		var props = {};
		var settingshtml = [];
		for (let prop of ['title','test','other'] ) {
			let test = $title.css("--" + prop);
			props[prop] = test;
			settingshtml.push(prop + ":" + props[prop]);
		}
		console.timeEnd("Getting properties");
		$title.html("<h1>" + props.title + "</h1>");
		$settings.html(settingshtml.join("<br>"));
	}
	function getMedia() {
		var width = $window.width();
		var minwidth = width;
		var maxwidth = width;
		var newmedium = "main";
		for (var smedium in media) {
			let m = media[smedium];
			// TODO: improve this: check "screen"
			if ( ("media" in m) ) {
				continue;
			}

			if ("max" in m && ( m.max > width )) {
				newmedium = smedium;
				maxwidth = m.max;
				
			}
			else if ("min" in m && ( m.min < width )) {
				newmedium = smedium;
				maxwidth = m.min;
			}
		}
		if (newmedium != medium) {
			medium = newmedium;
			displayMedia(medium + " Width " + width);
		}
	}

	
});
</script>

</body>
</html>

