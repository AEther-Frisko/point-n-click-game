class_name ContainerData extends Resource
## Data properties for any [Interactable]s that can contain an item.

## The data of the [Item] held by this object, if there is one.
@export var held_item: ItemData

## Should this [Interactable] disappear when its [Item] is picked up?
@export var is_item: bool
