# The State of the Clikpage nation

24/12/2022

## General Status

Working well and progress continues. The data sets functionality needs revisting. The names are confusing and the specification isn't ideal.

[Maintaining stylesheets](#stylesheets) is a complete pain. 

[Menus](#menus) need some finessing.

Popups working better than I had hoped. Decision made to split image popups and general popups.

Forms not done.

Galleries not done. TODO: make generic subsection functionality with categories.

## Menus { #menus}

Need to tidy up. With settings to control sub menu behaviour and also icons.

## Maintaing stylesheets { #stylesheets}

Will probably move to a system where we maintain the settings inline. The layout styles would be in the `<style>` tag for the layout and the content sections styling would be in a tag.

Could also have separate files for the schemes which you can find with ctrl+p. Also think about simple CSS parser.
