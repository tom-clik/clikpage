<!--

# Jquery Menu Test

-->
<cfscript>

pageObj = new clikpage.page(debug=1);
content = pageObj.getContent();
pageObj.addJs(content,"menus");
pageObj.addCss(content,"menus");
pageObj.addCss(content,"navbuttons");
pageObj.addCss(content,"/clikpage/_assets/css/schemes/menus-schemes.css");
pageObj.addJs(content,"modal");
pageObj.addJs(content,"autoButton");
content.title = "Menu test page";
</cfscript>

<cfsavecontent variable="content.css">
	:root {	
		/*****************************************************************
		*                              Colors                            *
		******************************************************************/
		--textcolor: #333333; /* Main text color */
		--myfavcolor: #ff0000; /* My favourite colour */
		--panel-bg: #01798a; /* Darker panel bg */
		--accent: #38bbcd; /* Accent colour */
		--panel-text: #ffffff; /* Panel text */
		--panel-overlay: rgba(33,33,33,0.4); /* Semi transparent overlay */
		--light-panel-bg: #eaeaea; /* Light panel packground */
		--linkcolor: #38bbcd; /* Link color */
		--overlaybg: rgba(0,0,0,0.2); /* Overlay background */
	}

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
	.cs-menu {
		--icon-width:1em;
		--icon-height:1em;
	}


</cfsavecontent>


<cfsavecontent variable="content.body">

	<div id="ubercontainer">
		<div class="button auto" id="menu_container_button">
			<a href="#menu_container.open">
				<div class="icon">
					<i class='icon-menu'></i>
				</div>
			</a>
		</div>

		<div id="menu_container">
			<div class="inner">
				<div class="button auto" id="menu_container_close_button">
					<a href="#menu_container.close">
						<div class="icon">
							<i class='icon-close'></i>
						</div>
					</a>
				</div>
				<div id='mainmenu' class='cs-menu scheme-vertical'>
<ul class='menu'><li><a href='?section=index'  class='menu_index'><span>Home page</span></a></li>
<li><a href='?section=gallery'  class='menu_gallery'><span>Gallery</span></a></li>
<li><a href='?section=gallery2'  class='menu_gallery2'><span>Gallery 2</span></a></li>
<li><a href='?section=about'  class='menu_about'><span>About</span></a></li>
<li><a href='?section=news'  class='menu_news'><span>News</span></a><ul class='submenu'><li><a href='{link.news.view.1}'  class='menu_submenu_news_1'><span>Article test 1</span></a></li>
<li><a href='{link.news.view.2}'  class='menu_submenu_news_2'><span>Article test 2</span></a></li>
<li><a href='{link.news.view.3}'  class='menu_submenu_news_3'><span>Article test 3</span></a></li>
<li><a href='{link.news.view.4}'  class='menu_submenu_news_4'><span>Article test 4</span></a></li>
</ul></li>
<li><a href='?section=newscarousel'  class='menu_newscarousel'><span>News carousel</span></a><ul class='submenu'><li><a href='{link.newscarousel.view.1}'  class='menu_submenu_newscarousel_1'><span>Article test 1</span></a></li>
<li><a href='{link.newscarousel.view.2}'  class='menu_submenu_newscarousel_2'><span>Article test 2</span></a></li>
<li><a href='{link.newscarousel.view.3}'  class='menu_submenu_newscarousel_3'><span>Article test 3</span></a></li>
<li><a href='{link.newscarousel.view.4}'  class='menu_submenu_newscarousel_4'><span>Article test 4</span></a></li>
</ul></li>
<li><a href='?section=images'  class='menu_images'><span>Images</span></a></li>
<li><a href='?section=singlearticle'  class='menu_singlearticle'><span>Single article</span></a></li>
</ul></div>
			</div>
		</div>	

	</div>

</cfsavecontent>


<cfsavecontent variable="onready">

	$(".button.auto").button();
	$plug = $('#menu_container');
	$plug.modal();
	$("#mainmenu").menu({animate:"height"});

</cfsavecontent>

<cfscript>
pageObj.addJs(content,onready);
writeOutput( pageObj.buildPage(content) );
</cfscript>