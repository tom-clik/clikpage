# Scroll fix

Scroll fix can be applied to a container to ensure it remains visible on the screen as the user scrolls down the page.

JavaScript is used to fix the container in position with the correct width.

## Implementation

Containers with scroll-fix set are checked to see if they are within the window. If not, a class of "scroll" is attached to the body and any styling specified in the `scroll` medium of the settings will kick in.

Note that other content can have scroll settings. Usually this is applied to items within than fixed container.

