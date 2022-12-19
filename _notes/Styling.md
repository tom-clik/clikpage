# CSS Tests

Working on a rebuild of the CSS for Clik. The conversion to grids and modern CSS was never really done properly.

## State of play

Originally I was just doing this for ColdLight. It went so well I have decided to incorporate it into Clik. Hence slight muddle over layout.

For Coldlight I was going to do everything with classes for all the settings. This didn't really work even without the requirement to fit into the Clik system. I have been going through the stylesheets and reverting to a system where the main stylesheets just contain simple CSS vars and any complex functionality is in the scheme stylesheets. In the Clik system, this is applied via settings.

There is still some confusion about fonts and colours etc. I did want to revert this as well and just use "panels". The wildcard here is the text styling where we have headings and titles, which are always a headache. Also linkcolor for menus uis very useful.

## Set up

For each of the types, there is a static CSS file in the coldLight directory and a test file. 

### Stylesheets

The static CSS should contain only simple vars and invariant styling. All complex settings should be applied in the scheme files.

### Testing files

There are static HTML test files in the coldlight directory. I am maintaining these for now but I want to replace them with the dynamic versions in the Clikpage testing folders. Will do this once the codebase has stabilised.

### Class styling

No classes should be required when using the dynamic mode. In the Clik system all functionality should be CSS based.

## CSS Vars

We make a distinction between "settings" and styles. Any variant styles are just css vars that can be set with a qualifier. Settings requires logic to output more complex styles.

### Typical application

The `text.css` contains styling for all the text. This is the least satisfactory part of it. There are separate definitions for main fonts, title fonts and header fonts. If we don't do this we struggle to keep the inheritance working.

## Column Layouts

Abandoned in favour of just using standard grid layouts with positions.

## General CS

Uses grid positions to do everything. NB everything is now kind of an item and the functionality is more generic.

## Popups

Images and general popups done differently. Images need javascript and also all the extra buttons. Other popups are just CSS with flexbox centering.

## Grids

See the separate notes for grids.

## Galleries

Just need the cropping etc options applied to grids (object cover??)

## Menus

Rudiments in place. Nice for everything bar sub sub menus.

Now need to get JavaScript sorted. Also fully expanded sub menus in horizontal mode.

## SVGS

You can apply css to an external svg with the `use` syntax.

    <svg  viewBox="0 0 197.4 197.4"><use href="graphics/left_arrow.svg#left_arrow" class="inlinebuttonSVG fillme"/></svg>

Not as neat as you'd like and viewport needs to be matched but it'll do.

## Text

Nice ideas for styling headings etc.

