# Zekrom's Extended Crafting API
### An easy way to extend crafting features
* Works with pools
* Damaging items
* Define input and output (Allowing storage **and** crafting)
* No consumption option
* Shaped crafting
* Define item alternative (via the `names` system)
* Dellays
* Checks for errors and trys to compensate for them (*Check your log!*)
* Automatic processing *(On press may not be posible, sorry)*
#### All of that easily used by people who don't know lua or complex JSON.

# How to set up
## Key
* `< >`: Indicaes that it is **optional** (Used instead of `[ ]` as in JSON it's an array)
* `...`: Indicates that it **continues**
* `/Path`: Defines the **path** from the **root** to the file
* `File`: Defineds the **file name** (including extention)
* `Bool`: Boolean `true` or `false`
* `Int`: A real **whole number**
* `Number`: Any **real number**
* `Array`: A **list of values** surounded by `[]`
* Note: The first container slot is `1`. **Not `0`!**  (`2` is `2`,... `n` is `n`)

## Object config
* `"/scripts"`: `/Path` Point to the **crafting script** (Can use [`/Path` <,`...`> ])
* `"/scriptDelta"`: `Int` Defines how **often** the script(s) run (The clock step is the scriptDelta)
* `"/multicraftAPI/input"`: `Array of 2 Int` Specifies the **input for crafting** | `Default([1, size])`
* `"/multicraftAPI/output"`: `Array of 2 Int` Specifies the **output for crafting** | `Default([1, size])`
* `"/multicraftAPI/recipefile"`: `/Path` Points to the **recipe JSON file**
* `"/multicraftAPI/drop"`: `"all" or Number` Decimal of **overflow droped** when broken (Positive numbers round up negative numbers round down) | `Default("all")`
* `"/multicraftAPI/killStorage"`: `Bool` Defines that the **storage overflow** should be **killed** | `Default(false)`
* `"/multicraftAPI/level"`: `Int` Defines the crafting object `level` | `Default(1)`
* `"/multicraftAPI/clockMax"`: `Int` Defines where the clock wraps | `Default(10000)`
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
}
...}
```

## Crafting config
### Due to the way the script works you can use an array or object at the root `/`
* `/Unique Identifier`: `String` Defines the **ID** for the recipe (To compensate for the lacking JSON-patch system)
* `"/input"`: `Array` Defines **paramaters** for the crafting `input`
	* `"/input/*/name"`: `String` The `item name` to check for
		* `"/input/*/count"`: `Int` The **amount** to check for
		* `"/input/*/names"`: `Array of String` Defines the posible `items` to use
		* `"/input/*/damage"`: `Number` How mutch to **damage the item** instead of consuming it (Positive numbers round up negative numbers round down) | `Default(null)`
		* `"/input/*/consume"`: `Bool` Defines whether to **consume the item** or not | `Default(false)`
* `"/output"`: `Array` Defines **paramaters** for the crafting `output`
	* `"/output/*/name"`: `String` The `item name` to give
		* `"/output/*/count"`: `String` The **amount** to give
	* `"/output/*/pool"`: `String` Defines the `pool` to generate
		* `"/output/*/level"`: `Int` The `pool level` to generate | `Default(0)`
* `"/delay"`: `Int` **Time** for the **item to craft** times the dt must be an integer | `Default(0)`
* `"/shaped"`: `Bool` Only runs in the **order given** instead of shapless | `Default(false)`
* `"/level"`: `Int` Defines the minumum crafting `level` required to craft | `Default(1)`
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
		{"name":`String`,"count":`Int`},
		{"pool":`String` <,"level": `Int`>}
	]
	<,"delay":`Int`>
	<,"shaped":`Bool`>
	<,"level":`Int`>
}...}
```
---
#### Using an array
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
## Item config for damage (Standard starbound config)

* `"/durability"`: `Int` The amount of `durability` an item has
	* `"/durabilityPerUse"`: `Int` How much `durability` to use **per use or craft** (Will consume item and will not jam with not enough durability)
```
{...
	"durability":`Int`,
	"durabilityPerUse":`Int`
...}
```

# Using functions in your lua file
Use `require /Path` to plug into the functions of each .lua file

---

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
Returns the `item name` or `object name` as well as the `object ID` for loging purposes.

### `Table or Object` Zutil.deepcopy(`Table or Object`)
Returns a copy of the `Object` or `Table` based off of http://lua-users.org/wiki/CopyTable