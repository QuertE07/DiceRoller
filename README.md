# DiceRoller

Tool intended for use as livestream or recording overlay, able to be keyed to anything that can interface with Godot signals, but set up for Stream Deck integration through [this plugin set](https://github.com/BoyneGames/streamdeck-godot-plugin) developed by [BoyneGames](https://github.com/BoyneGames).  
  
## Usage
  
### Building

Export for your platform of choice through Godot (instructions on how to do that [here](docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)) and you may run the application from there.  
  
Alternatively, navigate to the [latest release](https://github.com/QuertE07/DiceRoller/releases) if you just need the Windows version and download it from there.  
  
Place the contents of the `user_data` folder directly into one of these locations, dependent on platform:  
  
Windows: `%APPDATA%\RollingDice`  
macOS: `~/Library/Application Support/RollingDice`  
Linux: `~/.local/share/RollingDice`  
  
Once the [Stream Deck plugin](https://github.com/BoyneGames/streamdeck-godot-plugin) is installed, continue to next section.  
  
If you would prefer to activate the signal through another method, please modify the source code and/or plugins and rebuild to handle that as you see fit.  

---

### Integration

The signal method takes in a string input, arranged as a simple `"[command]_[inputNum],[inputNum],[inputNum]..."` format.  
  
These will be typed into the `Signal Input` field in Stream Deck as plain text (i.e. `switch_3`, not `"switch_3"`).  
  
Commands currently implemented are `"roll"`, `"switch"`, and `"clear"`.  
  
If more numbers are passed in than needed for the command in question, the program will simply not take them into account.  

#### "roll"

Input 7 numbers. These represent the number of d4, d6, d8, d10, d12 and d20 you wish to roll in that order, with the last number being the modifier you would like to apply.  
  
If you do not wish to roll any of a die with a specific side-count, leave the number in that location as `"0"`. Likewise applies to the modifier.  
  
When rolling, the previous set of active die is cleared from the box if applicable.
  
#### "switch"
  
Input 1 number. This represents the index of the profile in the `players.json` file you wish to fetch. If the number inputted is out of bounds, a player will not be fetched.  
  
For this step to use custom player names along with your own dice texture, you will have to modify the `players.json` file to include the names and texture paths they would like to use. You will also need to create the custom textures you intend to use for the dice, which you can place in the `textures` directory adjacent to the json file.  
  
#### "clear"

No numbers are taken into account as input. This can simply be inputted as `"clear"` and it will function as intended.  
  
This command will remove all current dice from the scene.
  
## Work in Progress
  
As the implementation of the d10 and d12 is not pressing for current usage, they have not been put together in a functional state. They may be updated to work in the future, however. More detailed/easily workable texture files may be added in the future as well.
  
## Tools/Plugins Used
  
### Tools:

[Godot 4.5](https://godotengine.org/)  
[Blender 5.0](https://www.blender.org/download/)  

### Plugins:

[streamdeck-godot-plugin](https://github.com/BoyneGames/streamdeck-godot-plugin) by [BoyneGames](https://github.com/BoyneGames)  
