# Steps for creating good issues.
### Bugs
1) Describe what whent wrong including, if applicable:
	* Item
	* Object
	* Monster
	* NPC
	* Action
2) Mention the current version of the mod and core mod.
3) Include a list of curent mods or link to your steam mod pack for Starbound.
4) Add the crash details from the log file found at `%ProgramFiles(x86)%\Steam\steamapps\common\Starbound\storage\starbound.log`
	* If posible remove the junk from the log file (I don't want a 1000 line log)
	* The layout of the log is `[<Time>] [<Type>] <Details>`
	* `<Time>`: Time the info was logged (in minitary time)
	* `<Type>`: Info / Warning / Error
	* `<Details>`: The actual information describing the error, warning, or information
5) If you modifed the game files or any mod files (Including custom mods), what did you do?

### Suggestions
1) What is it
2) Why should it be added
3) Any idea of how to impliment it

# Steps for creating good pull requests
1) Do not reolace any files unless necessary.
	* Always use JSON .patch files where applicable
	* Hook into .lua files if posible
2) Use tabs and not 4 spaces in your code to conserve data
3) Mention the changes that you have done
4) No explicit content

### Don't know how to mod but want to help?
* Pixle art
	1) Use .png files only.  __No .jepg!__
	2) Follow existing items such as [Zekrom pants](https://github.com/zekrom-vale/ZekromsKazdraAdditions/blob/master/ZekromsKazdraAdditions/ZekromsKazdraAdditions/items/armors/kazdra/zekrom/pantsm.png)
or [platforms](https://github.com/zekrom-vale/ZekromsKazdraRecipes/blob/master/ZekromsKazdraRecipes/ZekromsKazdraRecipes/tiles/platforms/woodgemplatform.png)
	3) Create on a grid where one tile is 8px by 8px _for tiles only_
	4) For __armor__ mention the 8 most used colors in [hex](https://www.google.com/search?q=rgb+to+hex) so they can be dyed
	5) Create an invintory icon 16px by 16px for most items
	6) Create a pull request adding your art in [this folder](https://github.com/zekrom-vale/ZekromsKazdraRecipes/tree/master/pixleArt)
# Links to external documentation
[Code of Conduct](https://github.com/zekrom-vale/ZekromsKazdraRecipes/blob/master/CODE_OF_CONDUCT.md)
