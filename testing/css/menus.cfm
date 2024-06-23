<!--

# Jquery Menu Test

-->
<cfscript>

pageObj = new clikpage.page(debug=1);
content = pageObj.getContent();
pageObj.addJs(content,"menus");
pageObj.addCss(content,"menus");
pageObj.addCss(content,"navbuttons");
content.title = "Menu test page";
</cfscript>

<cfsavecontent variable="content.css">
	#mainmenu {
		--menu-stretch:0
	}

</cfsavecontent>


<cfsavecontent variable="content.body">

	<div id="ubercontainer">
		

		<div id="menu_container">
			<div class="inner">
				
				<div id='mainmenu' class='cs-menu'>
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
</ul>
				</div>
			</div>
		</div>	

	</div>

</cfsavecontent>


<cfsavecontent variable="onready">

	$("#mainmenu").menu({animate:"height"});

</cfsavecontent>

<cfscript>
pageObj.addJs(content,onready);
writeOutput( pageObj.buildPage(content) );
</cfscript>