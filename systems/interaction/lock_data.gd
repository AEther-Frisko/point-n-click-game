class_name LockData extends Resource
## Data properties for any [Interactable] that can be locked.

signal lock_toggled()

## Locked/unlocked state of the [Interactable].
@export var is_locked: bool:
	set(new_state):
		is_locked = new_state
		lock_toggled.emit()

## [Item] needed to unlock the [Interactable].
@export var key_item: ItemData
