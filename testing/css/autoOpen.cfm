<!---

# Test auto open

Never really got this working.

Animate auto not working properly. Also this demo uses fixed widths and wouldn't work with this.

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
	<link rel="stylesheet" type="text/css" href="/_assets/css/media.css">	
	<meta charset="UTF-8">
	<style>
		body {
			--title-font:font-family: 'Open Sans';
		}
		img {
			max-width: 100%;
		}
		
		.item {
			height:100%;
			transition: width 0.6s ease-in;
		}

		#item1 {
			width:200px;
			background-color: teal;
		}

		.item.closed {
			width:0px !important;
			overflow: hidden;
		}

		#item2 {
			flex-grow: 1;
		}

		#item3 {
			--open:1;
			width:200px;
			background-color: teal;
		}

		body.media-mobile #item3 {
			--open:0;
		}

		#container {
			display: flex;
			height:400px;
		}
		.buttons {
			display: flex;
			grid-gap: 2px;
		}
		.button {
			border: 1px solid teal;
		}
		
		
	</style>
</head>
<body>

<div class="media-mobile">
	<h1>Mobile only</h1>
</div>
<div class="media-mid">
	<h1>Mid and below</h1>
</div>
<div class="media-midonly">
	<h1>Mid only</h1>
</div>
<div class="media-main">
	<h1>Main only</h1>
</div>
<div class="media-max">
	<h1>Max only</h1>
</div>

<div id="container">
<div id="item1" class="item autoopen">
Item 1
</div>
<div id="item2" class="item">
Item 2
</div>
<div id="item3" class="item autoopen">
Item 3
</div>
</div>


<div class="buttons">
<div class="button auto"><a id="open1_button" href="#item1.open">Open 1</a></div>
<div class="button auto"><a id="close1_button" href="#item1.close">Close 1</a></div>
<div class="button auto"><a id="open2_button" href="#item3.open">Open 3</a></div>
<div class="button auto"><a id="close2_button" href="#item3.close">Close 3</a></div>
</div>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.animateAuto.js"></script>	
<script src="/_assets/js/jquery.autoopen.js"></script>	
<script src="/_assets/js/jquery.throttledresize.js"></script>
<script src="/_assets/js/clik_common.js"></script>
<script src="/_assets/js/jquery.autoButton.js"></script>
<script src="/_assets/js/clik_onready.js"></script>
<!--- <script src="/_assets/js/_min/clikmain.0.9.min.js"></script> --->
<script src="/_assets/js/clik_common.js"></script>
<script src="/_assets/js/clik_onready.js"></script>

<script>

</script>
</body>
</html>
