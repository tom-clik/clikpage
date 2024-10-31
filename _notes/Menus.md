# Menus

## Status



Menus working ok but sub menu styling not done.

css_settings function needs breaking out with a recursive sub function. The sub mneus shouldbn't be in the selectors. It shuold recurse as required to two or three levels.

submenu_position should just be "position" for a sub key.

submenu can have a key of submenu for three layer menus.

Defaults for submenu should be inline for vertical? How??

Icons need sorting somehow.

## Menu structure



### Menu HTML



```html
<div id="menu" class="cs-menu scheme-name">
	<div class="menu">
		<ul>
			<li><a href="{{link.index}}" id="menu_index"><i class="icon-close"></i><span>Home page</span></a></li>
			<li class=""><a id="menu_gallery" class="hasmenu"><i class="icon-menu"></i><span>Gallery</span><i class="icon-next openicon"></i></a>
				<div class="cs-menu submenu">
					<div class="menu">
						<ul>
							<li><a href="{{link.gallery.view.1}}" id="menu_submenu_gallery_1"><i></i><span>Gallery test 1</span></a></li>
```

