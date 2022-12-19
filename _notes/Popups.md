# Popups

Popup containers and popup images are handled differently.

A container can be set to have a position of "popup" and can be opened and closed with a button action. These are configured manually and any contents styled normally.

A popup image is just an image content section with a position of "popup". Extra content items are automtically added for the buttons, which can be styled in the `next`, `previous`, and `close` sub keys.

A further sub key of `caption` can be used to style the caption, and `overlay` used to style the background.

## Styling a standard popup

For a standard popup, the container itself is the backdrop and any content just styled normally. To center a single item, set the grid mode to flex and center the contents.

See for examples `testings/css/popup.html`

