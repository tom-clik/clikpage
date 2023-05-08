<!--

# Jquery Menu Test

## Status

Not done

Currently just a copy of modal with a menu in it.

MUSTDO: rewrite the jquery.menu script using the standard skeleton.

## Synopsis

-->

<!DOCTYPE html>
<html>

<head>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/menus.css">
	<link rel="stylesheet" type="text/css" href="../content/_out/colors.css">
	<link rel="stylesheet" type="text/css" href="../content/_out/menu.css">
	<style>
	body {
		padding:20px;
		background-color: #ccc;
		--icon-width: 16px;
		--icon-height: 16px;
	}

	#ubercontainer {
		background-color: #fff;
		border: 1px solid #000;
		padding:20px;
		margin: 0 auto;
		max-width: 660px;
	}

	#menu_container {
		border:1px solid gray;
		padding:4px;
		display: block;
		position: fixed;
		top:0;
		left:0;
		transform: translate(-100%, 0);
		width:460px;
		height: 100vh;
		background-color: white;
		overflow: hidden;
		transition: transform 0.6s ease-in;
		box-shadow: rgba(50, 50, 93, 0.25) 0px 50px 100px -20px, rgba(0, 0, 0, 0.3) 0px 30px 60px -30px;
	}

	#menu_container > .inner {
		padding:20px
	}
	
	#menu_container.open {
		transform: translate(0);
	}
	#menu_container_button {
		--icon-width: 32px;
		--icon-height: 32px;
	}

	#menu_container_close_button {
		position: absolute;
		top:4px;
		right:4px;
	}

	.inner {
		height: 100%;
		width: 100%;
		display: relative;
	}

	.backdrop {
		background-color: rgba(0,0,0,0.3);
	}


	</style>
</head>

<body>

	<div id="ubercontainer">
		<div class="button auto" id="menu_container_button">
			<a href="#menu_container.open">
				<div class="icon">
					<svg   viewBox="0 0 448 512"><use xlink:href="/_assets/images/bars.svg#bars"></svg>
				</div>
			</a>
		</div>

		<div id="menu_container">
			<div class="inner">
				<div class="button auto" id="menu_container_close_button">
					<a href="#menu_container.close">
						<div class="icon">
							<svg   viewBox="0 0 357 357"><use xlink:href="/_assets/images/close47.svg#close"></svg>
						</div>
					</a>
				</div>
				<div id='mainmenu' class='cs-menu'>
<ul class='menu'><li><a href='?section=index'  class='menu_index'><b></b><span>Home page</span></a></li>
<li><a href='?section=gallery'  class='menu_gallery'><b></b><span>Gallery</span></a></li>
<li><a href='?section=gallery2'  class='menu_gallery2'><b></b><span>Gallery 2</span></a></li>
<li><a href='?section=about'  class='menu_about'><b></b><span>About</span></a></li>
<li><a href='?section=news'  class='menu_news'><b></b><span>News</span></a><ul class='submenu'><li><a href='{link.news.view.1}'  class='menu_submenu_news_1'><b></b><span>Article test 1</span></a></li>
<li><a href='{link.news.view.2}'  class='menu_submenu_news_2'><b></b><span>Article test 2</span></a></li>
<li><a href='{link.news.view.3}'  class='menu_submenu_news_3'><b></b><span>Article test 3</span></a></li>
<li><a href='{link.news.view.4}'  class='menu_submenu_news_4'><b></b><span>Article test 4</span></a></li>
</ul></li>
<li><a href='?section=newscarousel'  class='menu_newscarousel'><b></b><span>News carousel</span></a><ul class='submenu'><li><a href='{link.newscarousel.view.1}'  class='menu_submenu_newscarousel_1'><b></b><span>Article test 1</span></a></li>
<li><a href='{link.newscarousel.view.2}'  class='menu_submenu_newscarousel_2'><b></b><span>Article test 2</span></a></li>
<li><a href='{link.newscarousel.view.3}'  class='menu_submenu_newscarousel_3'><b></b><span>Article test 3</span></a></li>
<li><a href='{link.newscarousel.view.4}'  class='menu_submenu_newscarousel_4'><b></b><span>Article test 4</span></a></li>
</ul></li>
<li><a href='?section=images'  class='menu_images'><b></b><span>Images</span></a></li>
<li><a href='?section=singlearticle'  class='menu_singlearticle'><b></b><span>Single article</span></a></li>
</ul></div>
			</div>
		</div>	

	</div>

</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.throttledresize.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.autoButton.js"></script>
<script src="/_assets/js/jquery.modal.js"></script>
<script src="/_assets/js/jquery.menu.js"></script>

<script>
$(document).ready(function() {
	$(".button.auto").button();
	$plug = $('#menu_container');
	$plug.modal();
	$("#mainmenu").menu({
		arrow:"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 223.413 223.413\" preserveAspectRatio=\"none\"><use href=\"/_assets/images/right_arrow.svg#right_arrow\"></use></svg>"
	});
});
</script>

</html>