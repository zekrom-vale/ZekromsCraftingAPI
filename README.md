# Zekrom's Crafting API
### An easy way to extend crafting features
* Works with pools
* Damaging items
* Define input and output (Allowing storage **and** crafting)
* No consumption option
* Shaped crafting
* Dellays
* Checks for errors and trys to compensate for them (Check your log!)
* Automatic processing (Untill I find out how to wait for press button)
All of that easly used by people who don't know lua or complex JSON.

# How to set up
## Key
`[[ ]]`: Indicaes that it is optional
`...`: Indicates that it continues
`/Path`: Defines the path from the root to the file
`File`: Defineds the file name (including extention)
`Bool`: Boolian true or false
`Int`: A real whole number
`Number`: Any real number
`Array`: A list of values surounded by `[]` (Not `[[ ]]` in this key)

## Object config
* `"/scripts"`: `/Path` Point to the crafting script (Can use [`/Path` [[,`...`]] ])
* `"/scriptDelta"`: `Int` Defines how often the script(s) run (The clock step is the delta)
* `"/multicraftAPI/input"`: `Array of 2 Int` Specifies the input for crafting, container slot 1 is 1
* `"/multicraftAPI/output"`: `Array of 2 Int` Specifies the output for crafting, container slot 1 is 1
* `"/multicraftAPI/recipefile"`: `/Path` Points to the recipe JSON file
* `"/multicraftAPI/drop"`: `"all" or Number` Decimal of overflow droped broken (Positive numbers round up negative numbers round down)
* `"/multicraftAPI/killStorage"`: `Bool` Defines that the storage overflow should be killed
```
{...
"scripts":["/scripts/multicraft.lua"],
"scriptDelta": `Int`,
"multicraftAPI":{
	"input":[`Int`,`Int`],
	"output":[`Int`,`Int`],
	"recipefile":`/Path`
	[[,"drop":`"all" or Number`]]
	[[,"killStorage":`Bool`]]
}
...}
```

## Crafting config
* `"/input"`: `Array` Defines paramaters for the crafting input
	* `"/input/*/name"`: `String` The item name to check for
	* `"/input/*/count"`: `Int` The amount to check for
	* `"/input/*/damage"`: `Number` How mutch to damage the item instead of consuming it (Positive numbers round up negative numbers round down)
	* `"/input/*/consume"`: `Bool` Defines whether to consume the item or not
* `"/output"`:  `Array` Defines paramaters for the crafting output
	* `"/output/*/name"`: `String` The item name to give
	* `"/output/*/count"`: `String` The amount to give
	* OR `"/output/*/pool"`: `String` Defines the pool to generate
	* `"/output/*/level"`:
* `"/delay"`: `Int` Time for the item to craft times the dt must be an integer
* `"/shaped"`: Only runs in the order given instead of shapless
```
[{
	"input":[
		{"name":`String`,"count":`Int` [[,"damage":`Number`]] [[,"consume":`Bool`]]},
		{"name":`String`,"count":`Int`}
	],
	"output":[
		{"name":`String`,"count":`Int`},
		{"pool":`String` [[,"level": ``]]}
	]
	[[,"delay":`Int`]]
	[[,"shaped":`Bool`]]
}...]
```
## Item config for damage (Standard starbound config)

* `"/durability"`: `Int` The amount of durability an item has
* `"/durabilityPerUse"`: `Int` How much durability to use per use or craft (Will consume item and will not jam with not enough durability)
```
{...
	"durability":`Int`,
	"durabilityPerUse":`Int`
...}
```