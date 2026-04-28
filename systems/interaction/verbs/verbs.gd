extends Node
## Autoloaded wrapper for holding and pulling from the [VerbLibrary].

const LIBRARY: VerbLibrary = preload("uid://bqkadmk50sfwj")

var default: Verb:
	get: return LIBRARY.default

var look: Verb:
	get: return LIBRARY.look

var take: Verb:
	get: return LIBRARY.take

var walk: Verb:
	get: return LIBRARY.walk

var hold_item: Verb:
	get: return LIBRARY.hold_item

var use: Verb:
	get: return LIBRARY.use
