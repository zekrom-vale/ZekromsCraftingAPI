[big]Zekrom's Extended Crafting API (2 Part)[/big]
[small]An easy way to extend crafting features[/small]

[list]
[*] Works with pools
[*] Damaging items
[*] Define input and output (Allowing storage [b]and[/b] crafting)
[*] No consumption option
[*] Shaped crafting
[*] Define item alternative (via the `names` system)
[*] Delay
[*] Checks for errors and tries to compensate for them ([cur]Check your log![/cur])
[*] Automatic processing or click to craft
[*] Modes so you can use conflicting inputs (Ex wire extruder and plate press in one)
[*] Pull crafting script that works like the Minecraft crafting table
[/list]
All of that easily used by people who don't know lua or complex JSON.

[url=https://github.com/zekrom-vale/ZekromsCraftingAPI/tree/master#index]How to use this in your mod![/url]
[url=https://github.com/zekrom-vale/ZekromsCraftingAPI/tree/master#multicraft-the-standard-extended-crafting-1]Multicraft: The standard extended crafting[/url]
[url=https://github.com/zekrom-vale/ZekromsCraftingAPI/tree/master#pullcraft-craft-by-pulling-items-1]PullCraft: Craft by pulling items[/url]

[big]Index[/big]
[big]FAQ[/big]
[big]How to set up[/big]
Key
------------------------------------------
Multicraft: The standard extended crafting
------------------------------------------
Object config
Crafting config
Setting up trigger or modes for crafting to your interface config
Item config for damage
PullCraft: Craft by pulling items
------------------------------------------
Object config
Crafting config
Setting up modes
[big]Using functions in your lua file[/big]
ZekromsContainerUtil.lua
------------------------------------------
ZekromsItemUtil.lua
------------------------------------------
ZekromsUtil.lua
------------------------------------------

[big]FAQ[/big]
[list]
[*] Q: Is there a steam version of this?
[/list]
A: Yes there will be after I finish cleaning stuff up.
Q: I'm not a moder, do I need this?

A: You only need this mod if another mod requires it.  Otherwise, it is no use to you.
Q: Can I use this in my mod?

A: Yes, as long as you mention that this mod is required (As extended crafting will not work)
Q: Do I need to use `"require"` or `"includes"` to have this mod work?

A: This mod works after initialization is done so, no `"require"` or `"includes"` is not necisary (I think)
Q: Can I use your code?

A: It depends, what are you using it for?  (You can use the .lua functions that are listed below [b]AND[/b] include my mod as a required mod)
Q: I found an issue, where do I report it?

A: Go to the github issues section and post it there [b]if it is not already there![/b]  Also, include your starbound log [b]and[/b] the mod(s) you are using and that use this mod.
Q: Can I distribute this mod?

A: No, just link to this page or the steam page

[big]How to set up[/big]

[big]Key[/big]

[list]
[*] `< >`: Indicates that it is [b]optional[/b] (Used instead of `[ ]` as in JSON it's an array)
[*] `...`: Indicates that it [b]continues[/b]
[*] `/Path`: Defines the [b]path[/b] from the [b]root[/b] to the file
[*] `File`: Defines the [b]file name[/b] (including extension)
[*] `Bool`: Boolean `true` or `false`
[*] `Int`: A real [b]whole number[/b]
[*] `Number`: Any [b]real number[/b]
[*] `Array`: A [b]list of values[/b] surround by `[]`
[*] Note: The first container slot is `1`. [b]Not `0`![/b]  (`2` is `2`,... `n` is `n`)
[/list]
[big]Multicraft: The standard extended crafting[/big]

Object config
------------------------------------------

[list]
[*] `"/scripts"`: `/Path` Point to the [b]crafting script[/b] (Can use [`/Path` <,`...`> ])
[*] `"/scriptDelta"`: `Int` Defines how [b]often[/b] the script(s) run (The clock step is the scriptDelta)
[*] `"/multicraftAPI/input"`: `Array of 2 Int` Specifies the [b]input for crafting[/b] | `Default([1, size])`
[*] `"/multicraftAPI/output"`: `Array of 2 Int` Specifies the [b]output for crafting[/b] | `Default([1, size])`
[*] `"/multicraftAPI/recipefile"`: `/Path` Points to the [b]recipe JSON file[/b]
[*] `"/multicraftAPI/drop"`: `"all" or Number` Decimal of [b]overflow dropped[/b] when broken (Positive numbers round up negative numbers round down) | `Default("all")`
[*] `"/multicraftAPI/killStorage"`: `Bool` Defines that the [b]storage overflow[/b] should be [b]killed[/b] | `Default(false)`
[*] `"/multicraftAPI/level"`: `Int` Defines the crafting object `level` | `Default(1)`
[*] `"/multicraftAPI/clockMax"`: `Int` Defines where the clock wraps | `Default(10000)`
[*] `"/multicraftAPI/modeMax"`: `Int` Defines the amount of modes (1 to n)[code]
{...
"scripts":["/scripts/multicraft.lua"],
"scriptDelta": `Int`,
"multicraftAPI":{
"input":[`Int`,`Int`],
"output":[`Int`,`Int`],
"recipefile"`:/Path`
<,"drop"`:"all" or Number`>
<,"killStorage"`:Bool`>
<,"level"`:Int`>
<,"clockMax": `Int`>
<,"modeMax": `Int`>
}
...}
[/code]
[/list]
Crafting config
------------------------------------------

Due to the way the script works you can use an array or object at the root `/`

[list]
[*] `/Unique Identifier`: `String` Defines the [b]ID[/b] for the recipe (To compensate for the lacking JSON-patch system)
[*] `"/input"`: `Array` Defines [b]paramaters[/b] for the crafting `input`
[list][*] `"/input/*/name"`: `String` The `item name` to check for
[list][*] `"/input/*/count"`: `Int` The [b]amount[/b] to check for
[*] `"/input/[cur]/names"`: `Array of String` Defines the possible `items` to use
[[/cur]] `"/input/*/damage"`: `Number` How much to [b]damage the item[/b] instead of consuming it (Positive numbers round up negative numbers round down) | `Default(null)`
[*] `"/input/*/consume"`: `Bool` Defines whether to [b]consume the item[/b] or not | `Default(false)`[/list][/list]
[*] `"/output"`: `Array` Defines [b]paramaters[/b] for the crafting `output`
[list][*] `"/output/*/name"`: `String` The `item name` to give
[list][*] `"/output/*/count"`: `String` The [b]amount[/b] to give[/list]
[*] `"/output/*/pool"`: `String` Defines the `pool` to generate
[list][*] `"/output/*/level"`: `Int` The `pool level` to generate | `Default(0)`[/list][/list]
[*] `"/delay"`: `Int` [b]Time[/b] for the [b]item to craft[/b] times the dt must be an integer | `Default(0)`
[*] `"/shaped"`: `Bool` Only runs in the [b]order given[/b] instead of shapeless | `Default(false)`
[*] `"/level"`: `Int` Defines the minimum crafting `level` required to craft | `Default(1)`
[/list]
Using an object (Recommended)[code]

{
`Unique Identifier`:{
    "input":[
        {"name"`:String`,"count"`:Int` <,"damage"`:Number`> <,"consume"`:Bool`>},
        {},//Empty slot only for shaped
        {"names"`:Array of String`,"count"`:Int` <,"damage"`:Number`> <,"consume"`:Bool`>}
    ],
    "output":[
        {"name"`:String`,"count"`:Int`},
        {"pool"`:String` <,"level": `Int`>}
    ]
    <,"delay"`:Int`>
    <,"shaped"`:Bool`>
    <,"level"`:Int`>
}...}
[/code]---

Using an array[code]

[{
    "input":[
        {"name"`:String`,"count"`:Int` <,"damage"`:Number`> <,"consume"`:Bool`>},
        {},//Empty slot only for shaped
        {"names"`:Array of String`,"count"`:Int` <,"damage"`:Number`> <,"consume"`:Bool`>}
    ],
    "output":[
        {"name"`:String`,"count"`:Int`},
        {"pool"`:String` <,"level": `Int`>}
    ]
    <,"delay"`:Int`>
    <,"shaped"`:Bool`>
    <,"level"`:Int`>
}...]
[/code]
Setting up trigger or modes for crafting to your interface config (Click to craft)
[list]
[*] [code]"/gui/[/code]yourButton[code]/callback"[/code]: "trigger" Defines that the button runs trigger() to start crafting
[*] [code]"/gui/[/code]yourButton2[code]/callback"[/code]: "mode" Defines that the button runs mode() to switch modes
[*] [code]"/scriptWidgetCallbacks"[/code]: [<"trigger"><,"mode">] Defines the functions that can be called
[*] [code]"/scripts/-"[/code]: "/scripts/ZekTrigger.lua" Defines the script the functions are in
[/list]
[code]
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
[/code]

Item config for damage (Standard starbound config)
------------------------------------------

[list]
[*] `"/durability"`: `Int` The amount of `durability` an item has
[list][*] `"/durabilityPerUse"`: `Int` How much `durability` to use [b]per use or craft[/b] (Will consume item and will not jam with not enough durability)[code]
{...
"durability"`:Int`,
"durabilityPerUse"`:Int`
...}[/list]
[/list]
[/code]

[big]PullCraft: Craft by pulling items[/big]

The config is very similar to the multicraft system, but is more limited

Drops mismatched items in the output when working to fix a consumption issue

Object config
------------------------------------------

[list]
[*] `"/scripts"`: `/Path` Point to the [b]crafting script[/b] (Can use [`/Path` <,`...`> ])
[*] `"/scriptDelta"`: `Int` Defines how [b]often[/b] the script(s) run (The clock step is the scriptDelta)
[*] `"/multicraftAPI/input"`: `Array of 2 Int` Specifies the [b]input for crafting[/b] | `Default([1, size])`
[*] `"/multicraftAPI/output"`: `Array of 2 Int` Specifies the [b]output for crafting[/b] | `Default([1, size])`
[*] `"/multicraftAPI/recipefile"`: `/Path` Points to the [b]recipe JSON file[/b]
[*] `"/multicraftAPI/level"`: `Int` Defines the crafting object `level` | `Default(1)`
[*] `"/multicraftAPI/modeMax"`: `Int` Defines the amount of modes (1 to n)
[/list]
[code]
{...
"scripts":["/scripts/pullCraft.lua"],
"scriptDelta": `Int`,
"multicraftAPI":{
"input":[`Int`,`Int`],
"output":[`Int`,`Int`],
"recipefile"`:/Path`
<,"level"`:Int`>
<,"modeMax": `Int`>
}
...}
[/code]
Crafting config

Due to the way the script works you can use an array or object at the root `/`
[list]
[*] `/Unique Identifier`: `String` Defines the [b]ID[/b] for the recipe (To compensate for the lacking JSON-patch system)
[*] `"/input"`: `Array` Defines [b]paramaters[/b] for the crafting `input`
[list][*] `"/input/*/name"`: `String` The `item name` to check for
[list][*] `"/input/*/count"`: `Int` The [b]amount[/b] to check for
[*] `"/input/[cur]/names"`: `Array of String` Defines the possible `items` to use
[[/cur]] `"/input/*/damage"`: `Number` How much to [b]damage the item[/b] instead of consuming it (Positive numbers round up negative numbers round down) | `Default(null)`
[*] `"/input/*/consume"`: `Bool` Defines whether to [b]consume the item[/b] or not | `Default(false)`[/list][/list]
[*] `"/output"`: `Array` Defines [b]paramaters[/b] for the crafting `output`
[list][*] `"/output/*/name"`: `String` The `item name` to give
[list][*] `"/output/*/count"`: `String` The [b]amount[/b] to give[/list][/list]
[*] `"/shaped"`: `Bool` Only runs in the [b]order given[/b] instead of shapeless | `Default(false)`
[*] `"/level"`: `Int` Defines the minimum crafting `level` required to craft | `Default(1)`
[/list]
Using an object (Recommended)[code]

{
`Unique Identifier`:{
    "input":[
        {"name"`:String`,"count"`:Int` <,"damage"`:Number`> <,"consume"`:Bool`>},
        {},//Empty slot only for shaped
        {"names"`:Array of String`,"count"`:Int` <,"damage"`:Number`> <,"consume"`:Bool`>}
    ],
    "output":[
        {"name"`:String`,"count"`:Int`}
    ]
    <,"shaped"`:Bool`>
    <,"level"`:Int`>
}...}
[/code]

Setting up modes
------------------------------------------

[list]
[*] `"/gui/`yourButton`/callback"`: "mode" Defines that the button runs mode() to switch modes
[*] `"/scriptWidgetCallbacks"`: ["mode"] Defines the functions that can be called
[*] `"/scripts/-"`: "/scripts/ZekTrigger.lua" Defines the script the functions are in[code]
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
[/list]
[big][/code][/big]

[big]Using functions in your lua file[/big]

Use `require /Path` to plug into the functions of each .lua file

[big]ZekromsContainerUtil.lua[/big]

`bool` Zcontainer.consumeAt(`item descriptor` item , `Array of 2 Int` range)
------------------------------------------

Consumes the given `item` within the `range` given.  Returns `true` if successful and `false` otherwise.

`Bool or Object` Zcontainer.putAt(`item descriptor` item, `Array of 2 Int` range)
------------------------------------------

Trys to insert the `item` within the given `range` returns the `item descriptor` of the overflow or `true` if there is no overflow.

[big]ZekromsItemUtil.lua[/big]

`bool` Zitem.damage(`item descriptor` item [,`Array of Int` range])
------------------------------------------

Damages the `item` and removes it if the durabilityHit is grater than or equal to the durability in the given range or `self.input`.  Returns `false` if it fails, and `true` otherwise.  Add `item.damage` to change the factor just like in the Crafting config at `"/input/*/damage"`

[big]ZekromsUtil.lua[/big]

`String` Zutil.sbName()
------------------------------------------

Returns the `item name` or `object name` as well as the `object ID` for logging purposes.

`Table or Object` Zutil.deepcopy(`Table or Object`)
------------------------------------------

Returns a copy of the `Object` or `Table` based off of http://lua-users.org/wiki/CopyTable

[big]Notes[/big]

[list]
[*] `nil` is lua's `null` or `undefined` value
[/list]