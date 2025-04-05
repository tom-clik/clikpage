# Icons

Icons use fonts to display images in buttons and menu items.

The actual content of the icon is applied via a CSS var `--menu-icon`.

Only this needs changing for any given button or menu item.

## Button names

As with colors and font families, they are abstracted. This is a level more complicated than normal variables, as we then need to assign the relevant font character(s).

We have tried to establish a common set of names for the variables, and a CSS file would these as required.

A typical stylesheet entry looks like this:

```
--menu-icon: var(--icon-home);
```

And a typical font css file (using Google) looks like this:

```
body {
	--icon-close: "close";
	--icon-menu: "menu";
```

or Font Awesome

```
body {
	--icon-close:"\f410";
	--icon-menu: "\f0c9";  
}
```

The definitions are often put into a separate file to allow for offline previewing with local versions of the scripts.

The production version looks something like this:

```
@import url('https://fonts.googleapis.com/icon?family=Material+Icons');
@import url('google_icons_codes.css');
```

and a local version something like:

```
@import url('google_icons_codes.css');

@font-face {
  font-family: 'Material Icons';
  font-style: normal;
  font-weight: 400;
  src: local('Material Icons');
}
```






