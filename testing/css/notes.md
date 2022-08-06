# CSS Tests

Working on a rebuild of the CSS for Clik. The conversion to grids and modern CSS was never really done properly.


## State of play

Originally I was just doing this for ColdLight. It went so well I have decided to incorporate it into Clik. Hence slight muddle over layout.

## Set up

### Script files

For each of the types, there is a static CSS file in the coldLight directory which is read into our test folder by CF script `asset_proxy.cfm`.

### Testing files

Each testing file contains testing HTML and the start of a script to generate the settings for the type.

### Class styling

Some styling is still being assigned by classes. There should be no reason for this in the new system, and all styling should be appliable for any viewport without the use of long lists of class names. 

### Sample scheme styles

Where I developed the CSS I created some sample schemes. These are just WIP and everything should eventually be rolled into the styling.

## CSS Vars

Everything we do now is focussed on CSS vars.

Instead of assigning CSS values for every identifier, we try to only set CSS variables. This almost provides a degree of inheritance to CSS.

### Typical application

The `text.css` contains styling for all the text. This is the least satisfactory part of it. There are separate definitions for main fonts, title fonts and header fonts. If we don't do this we struggle to keep the inheritance working.

## Column Layouts

Working really nicely with grids and no JS.

No need to change any column orders etc, just uses grid positions. 

Uses a new syntax for the column orders. A dash separates the columsn vertically, an

### Page Row layouts

The same syntax style is used to determine the rows in the uber container. This is mainly to omit and change the order. The only realy grid variation is the option to fix the header, footer, or topnav by appending an F, and to place the topnav and content in the same column using TC. The top nave can also be set to popup with P. This is currently experimental.


## General cs layouts

Uses grid template areas to avoid all HTML issues

NB will change articles just to use this.

## Popups

Just can't get the info box to center. Will need some sort of javascript.

## Grids

Oh so beautiful. Loving it.

## Galleries

Just need the cropping etc options applied to grids (object cover??)

## Menus

Rudiments in place. Nice for everything bar sub sub menus.

Now need to get JavaScript sorted. Also fully expanded sub menus in horizontal mode.

## SVGS

You can apply css to an external svg with a bit of a bodge. By referencing a part of an external SVG for reuse, you can apply styling to the `use` element. These then cascade. Its enough for stroke and fill.

    <svg  viewBox="0 0 197.4 197.4"><use href="graphics/left_arrow.svg#left_arrow" class="inlinebuttonSVG fillme"/></svg>

Not as neat as you'd like and viewport needs to be matched but it'll do.

## Text

Nice ideas for styling headings etc.

