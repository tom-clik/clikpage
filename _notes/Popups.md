# Popups

Popup containers and popup images are handled differently.

A container can be set to have a position of "popup" and can be opened and closed with a button action. These are configured manually and any contents styled normally.

A popup image is just an image content section with a position of "popup". Extra content items are automtically added for the buttons, which can be styled in the `next`, `previous`, and `close` sub keys.

A further sub key of `caption` can be used to style the caption, and `overlay` used to style the background.

## Styling a standard popup

For a standard popup, the container itself is the backdrop and any content just styled normally. To center a single item, set the grid mode to flex and center the contents.

See for examples `testings/css/popup.html`

If you want a close button, you need a wrapper to put it into (see also the example page).

## Image popup

An image popup needs to generate some of the content automatically. This includes the backdrop and the buttons.

It also needs to be able to "follow" any linked image set. To do this, we set a field of "controls" on the images component. When the an image is selected in that (either a carousel or plain grid), this calls "goTo" on the main image set.

The popup also needs to call goTo on the controlling content section if it's e.g. a carousel. 

