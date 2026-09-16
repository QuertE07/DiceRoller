# DiceRoller

Tool intended for use as livestream or recording overlay, able to be keyed to anything that can interface with Godot signals, but set up for Stream Deck integration through [this plugin set](https://github.com/BoyneGames/streamdeck-godot-plugin) developed by BoyneGames.  
  
## Usage
  
### Building

Export for your platform of choice through Godot (instructions on how to do that [here](docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html) and you may run the application from there.  
  
Once Stream Deck plugin is installed, continue to next section.  
  
If you would prefer to activate the signal through another method, please modify the code and/or plugins to handle that as you see fit.  
  
### Integration

The signal method takes in a string input, formatted as a simple `"[command]_[inputNum],[inputNum],[inputNum]..."` format.  
Commands implemented are `"roll"`, `"switch"`, and `"clear"`.  
  
If more numbers are passed in than needed for the command in question, the program will simply not take them into account.  

#### "roll"

Input 7 numbers. These represent the number of d4, d6, d8, d10, d12 and d20 you wish to roll in that order, with the last number being the modifier you would like to apply.  
If you do not wish to roll any of a die with a specific side-count, leave the number in that location as `"0"`. Likewise applies to the modifier.  
  
When rolling, the previous set of active die is cleared from the box if applicable.

#### "switch"

Input 1 number. This represents the index of the profile in the `players.json` file you wish to fetch. If the number inputted is out of bounds, a player will not be fetched.  
  
For this step to not use the default player names along with the provided dice base texture, you will have to modify the `players.json` file to include the names and texture paths they would like to use.  

#### "clear"

No numbers are taken into account as input. This can simply be inputted as `"clear"` and it will function as intended.  
This command will remove all current dice from the scene.
