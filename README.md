# Zekrom's Extended Crafting API (2 Part)
### An easy way to extend crafting features
* Works with pools
* Damaging items
* Define input and output (Allowing storage **and** crafting)
* No consumption option
* Shaped crafting
* Define item alternative (via the `names` system)
* Delay
* Checks for errors and tries to compensate for them (*Check your log!*)
* Automatic processing or click to craft
* Modes so you can use conflicting inputs (Ex wire extruder and plate press in one)
* Pull crafting script that works like the Minecraft crafting table
#### All of that easily used by people who don't know lua or complex JSON.

# Index
## [FAQ](#faq-1)
## [How to set up](#how-to-set-up-1)
### [Key](#key-1)
### [Multicraft: The standard extended crafting](#multicraft-the-standard-extended-crafting-1)
#### [Object config](#object-config-2)
#### [Crafting config](#crafting-config-2)
#### [Setting up trigger or modes for crafting to your interface config](#setting-up-trigger-or-modes-for-crafting-to-your-interface-config-click-to-craft)
#### [Item config for damage (Standard starbound config)](#item-config-for-damage-standard-starbound-config-1)
### [PullCraft: Craft by pulling items](#pullcraft-craft-by-pulling-items-1)
#### [Object config](#object-config-3)
#### [Crafting config](#crafting-config-3)
#### [Setting up modes](#setting-up-modes)
## [Using functions in your lua file](#using-functions-in-your-lua-file-1)
### [ZekromsContainerUtil.lua](#zekromscontainerutillua-1)
### [ZekromsItemUtil.lua](#zekromsitemutillua-1)
### [ZekromsUtil.lua](#zekromsutillua-1)
---

# FAQ
* Q: Is there a steam version of this?

A: Yes there will be after I finish cleaning stuff up.
* Q: I'm not a moder, do I need this?

A: You only need this mod if another mod requires it.  Otherwise, it is no use to you.
* Q: Can I use this in my mod?

A: Yes, as long as you mention that this mod is required (As extended crafting will not work)
* Q: Do I need to use `"require"` or `"includes"` to have this mod work?

A: This mod works after initialization is done so, no `"require"` or `"includes"` is not necisary (I think)
* Q: Can I use your code?

A: It depends, what are you using it for?  (You can use the .lua functions that are listed below **AND** include my mod as a required mod)
* Q: I found an issue, where do I report it?

A: Go to the github issues section and post it there **if it is not already there!**  Also, include your starbound log **and** the mod(s) you are using and that use this mod.
* Q: Can I distribute this mod?

A: No, just link to this page or the steam page

# How to set up
## Key
* `< >`: Indicates that it is **optional** (Used instead of `[ ]` as in JSON it's an array)
* `...`: Indicates that it **continues**
* `/Path`: Defines the **path** from the **root** to the file
* `File`: Defines the **file name** (including extension)
* `Bool`: Boolean `true` or `false`
* `Int`: A real **whole number**
* `Number`: Any **real number**
* `Array`: A **list of values** surround by `[]`
* Note: The first container slot is `1`. **Not `0`!**  (`2` is `2`,... `n` is `n`)

## Multicraft: The standard extended crafting
### Object config
* `"/scripts"`: `/Path` Point to the **crafting script** (Can use [`/Path` <,`...`> ])
* `"/scriptDelta"`: `Int` Defines how **often** the script(s) run (The clock step is the scriptDelta)
* `"/multicraftAPI/input"`: `Array of 2 Int` Specifies the **input for crafting** | `Default([1, size])`
* `"/multicraftAPI/output"`: `Array of 2 Int` Specifies the **output for crafting** | `Default([1, size])`
* `"/multicraftAPI/recipefile"`: `/Path` Points to the **recipe JSON file**
* `"/multicraftAPI/drop"`: `"all" or Number` Decimal of **overflow dropped** when broken (Positive numbers round up negative numbers round down) | `Default("all")`
* `"/multicraftAPI/killStorage"`: `Bool` Defines that the **storage overflow** should be **killed** | `Default(false)`
* `"/multicraftAPI/level"`: `Int` Defines the crafting object `level` | `Default(1)`
* `"/multicraftAPI/clockMax"`: `Int` Defines where the clock wraps | `Default(10000)`
* `"/multicraftAPI/modeMax"`: `Int` Defines the amount of modes (1 to n)
```
{...
"scripts":["/scripts/multicraft.lua"],
"scriptDelta": `Int`,
"multicraftAPI":{
	"input":[`Int`,`Int`],
	"output":[`Int`,`Int`],
	"recipefile":`/Path`
	<,"drop":`"all" or Number`>
	<,"killStorage":`Bool`>
	<,"level":`Int`>
	<,"clockMax": `Int`>
	<,"modeMax": `Int`>
}
...}
```

### Crafting config
#### Due to the way the script works you can use an array or object at the root `/`
* `/Unique Identifier`: `String` Defines the **ID** for the recipe (To compensate for the lacking JSON-patch system)
* `"/input"`: `Array` Defines **paramaters** for the crafting `input`
	* `"/input/*/name"`: `String` The `item name` to check for
		* `"/input/*/count"`: `Int` The **amount** to check for
		* `"/input/*/names"`: `Array of String` Defines the possible `items` to use
		* `"/input/*/damage"`: `Number` How much to **damage the item** instead of consuming it (Positive numbers round up negative numbers round down) | `Default(null)`
		* `"/input/*/consume"`: `Bool` Defines whether to **consume the item** or not | `Default(false)`
* `"/output"`: `Array` Defines **paramaters** for the crafting `output`
	* `"/output/*/name"`: `String` The `item name` to give
		* `"/output/*/count"`: `String` The **amount** to give
	* `"/output/*/pool"`: `String` Defines the `pool` to generate
		* `"/output/*/level"`: `Int` The `pool level` to generate | `Default(0)`
* `"/delay"`: `Int` **Time** for the **item to craft** times the dt must be an integer | `Default(0)`
* `"/shaped"`: `Bool` Only runs in the **order given** instead of shapeless | `Default(false)`
* `"/level"`: `Int` Defines the minimum crafting `level` required to craft | `Default(1)`
##### Using an object (Recommended)
```
{
`Unique Identifier`:{
	"input":[
		{"name":`String`,"count":`Int` <,"damage":`Number`> <,"consume":`Bool`>},
		{},//Empty slot only for shaped
		{"names":`Array of String`,"count":`Int` <,"damage":`Number`> <,"consume":`Bool`>}
	],
	"output":[
		{"name":`String`,"count":`Int`},
		{"pool":`String` <,"level": `Int`>}
	]
	<,"delay":`Int`>
	<,"shaped":`Bool`>
	<,"level":`Int`>
}...}
```
---
##### Using an array
```
[{
	"input":[
		{"name":`String`,"count":`Int` <,"damage":`Number`> <,"consume":`Bool`>},
		{},//Empty slot only for shaped
		{"names":`Array of String`,"count":`Int` <,"damage":`Number`> <,"consume":`Bool`>}
	],
	"output":[
		{"name":`String`,"count":`Int`},
		{"pool":`String` <,"level": `Int`>}
	]
	<,"delay":`Int`>
	<,"shaped":`Bool`>
	<,"level":`Int`>
}...]
```
### Setting up trigger or modes for crafting to your interface config (Click to craft)
* `"/gui/`yourButton`/callback"`: "trigger" Defines that the button runs trigger() to start crafting
* `"/gui/`yourButton2`/callback"`: "mode" Defines that the button runs mode() to switch modes
* `"/scriptWidgetCallbacks"`: [<"trigger"><,"mode">] Defines the functions that can be called
* `"/scripts/-"`: "/scripts/ZekTrigger.lua" Defines the script the functions are in
```
{
"gui":{
	...
	"yourButton":{
		"type":"button",
		...
		"callback":"trigger"
	},
	"yourButton2":{
		"type":"button",
		...
		"callback":"mode"
	},
	...
},
"scriptWidgetCallbacks":[<"trigger"><,"mode">],
"scripts":["/scripts/ZekTrigger.lua"]
}
```

### Item config for damage (Standard starbound config)

* `"/durability"`: `Int` The amount of `durability` an item has
	* `"/durabilityPerUse"`: `Int` How much `durability` to use **per use or craft** (Will consume item and will not jam with not enough durability)
```
{...
	"durability":`Int`,
	"durabilityPerUse":`Int`
...}
```

---
## PullCraft: Craft by pulling items
##### The config is very similar to the multicraft system, but is more limited
##### Drops mismatched items in the output when working to fix a consumption issue
### Object config
* `"/scripts"`: `/Path` Point to the **crafting script** (Can use [`/Path` <,`...`> ])
* `"/scriptDelta"`: `Int` Defines how **often** the script(s) run (The clock step is the scriptDelta)
* `"/multicraftAPI/input"`: `Array of 2 Int` Specifies the **input for crafting** | `Default([1, size])`
* `"/multicraftAPI/output"`: `Array of 2 Int` Specifies the **output for crafting** | `Default([1, size])`
* `"/multicraftAPI/recipefile"`: `/Path` Points to the **recipe JSON file**
* `"/multicraftAPI/level"`: `Int` Defines the crafting object `level` | `Default(1)`
* `"/multicraftAPI/modeMax"`: `Int` Defines the amount of modes (1 to n)
```
{...
"scripts":["/scripts/pullCraft.lua"],
"scriptDelta": `Int`,
"multicraftAPI":{
	"input":[`Int`,`Int`],
	"output":[`Int`,`Int`],
	"recipefile":`/Path`
	<,"level":`Int`>
	<,"modeMax": `Int`>
}
...}
```

### Crafting config
#### Due to the way the script works you can use an array or object at the root `/`
* `/Unique Identifier`: `String` Defines the **ID** for the recipe (To compensate for the lacking JSON-patch system)
* `"/input"`: `Array` Defines **paramaters** for the crafting `input`
	* `"/input/*/name"`: `String` The `item name` to check for
		* `"/input/*/count"`: `Int` The **amount** to check for
		* `"/input/*/names"`: `Array of String` Defines the possible `items` to use
		* `"/input/*/damage"`: `Number` How much to **damage the item** instead of consuming it (Positive numbers round up negative numbers round down) | `Default(null)`
		* `"/input/*/consume"`: `Bool` Defines whether to **consume the item** or not | `Default(false)`
* `"/output"`: `Array` Defines **paramaters** for the crafting `output`
	* `"/output/*/name"`: `String` The `item name` to give
		* `"/output/*/count"`: `String` The **amount** to give
* `"/shaped"`: `Bool` Only runs in the **order given** instead of shapeless | `Default(false)`
* `"/level"`: `Int` Defines the minimum crafting `level` required to craft | `Default(1)`
#### Using an object (Recommended)
```
{
`Unique Identifier`:{
	"input":[
		{"name":`String`,"count":`Int` <,"damage":`Number`> <,"consume":`Bool`>},
		{},//Empty slot only for shaped
		{"names":`Array of String`,"count":`Int` <,"damage":`Number`> <,"consume":`Bool`>}
	],
	"output":[
		{"name":`String`,"count":`Int`}
	]
	<,"shaped":`Bool`>
	<,"level":`Int`>
}...}
```

### Setting up modes
* `"/gui/`yourButton`/callback"`: "mode" Defines that the button runs mode() to switch modes
* `"/scriptWidgetCallbacks"`: ["mode"] Defines the functions that can be called
* `"/scripts/-"`: "/scripts/ZekTrigger.lua" Defines the script the functions are in
```
{
"gui":{
	...
	"yourButton":{
		"type":"button",
		...
		"callback":"mode"
	},
	...
},
"scriptWidgetCallbacks":["mode"],
"scripts":["/scripts/ZekTrigger.lua"]
}
```

---

# Using functions in your lua file
Use `require /Path` to plug into the functions of each .lua file

## ZekromsContainerUtil.lua
### `bool` Zcontainer.consumeAt(`item descriptor` item , `Array of 2 Int` range)
Consumes the given `item` within the `range` given.  Returns `true` if successful and `false` otherwise.

### `Bool or Object` Zcontainer.putAt(`item descriptor` item, `Array of 2 Int` range)
Trys to insert the `item` within the given `range` returns the `item descriptor` of the overflow or `true` if there is no overflow.

## ZekromsItemUtil.lua
### `bool` Zitem.damage(`item descriptor` item [,`Array of Int` range])
Damages the `item` and removes it if the durabilityHit is grater than or equal to the durability in the given range or `self.input`.  Returns `false` if it fails, and `true` otherwise.  Add `item.damage` to change the factor just like in the Crafting config at `"/input/*/damage"`

## ZekromsUtil.lua
### `String` Zutil.sbName()
Returns the `item name` or `object name` as well as the `object ID` for logging purposes.

### `Table or Object` Zutil.deepcopy(`Table or Object`)
Returns a copy of the `Object` or `Table` based off of http://lua-users.org/wiki/CopyTable

# Notes
* `nil` is lua's `null` or `undefined` value
