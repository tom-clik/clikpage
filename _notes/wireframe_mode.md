# Wireframe Mode

Wireframe mode allows you to see all the containers on a layout in a schematic.

The containers can be re-arranged easily and the styling dialog accessed by selecting the container and pressing `S`.

It's used when the conatiners or content aren't easily accessible on normal preview.

## Implementation

In wireframe mode, the content items are shown without any content and just their titles.

For a given layout, apply wf-container and wf-content to each item as appropriate. Just the title will be shown in a label container.

### Styling

Applied via the editing.css script. 

wf-container 
wf-content

### Layers

The layers functionality allows you to remove the content sections according to their position in the document hierarchy.

To apply layers we traverse the document tree and apply a wp-layer-number class as we go down.

Implementation: todo.