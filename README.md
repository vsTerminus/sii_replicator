Create template .sii files using "%truck%" anywhere you would normally put the truck name. Put them in a folder. The folder name doesn't matter to the script.

List the trucks you want to support in "trucks.txt", one per line. You need to use the folder name for the truck, eg "peterbilt.389"

When you run genconfig.pl pass in the folder you want it to process as the only argument. It will create a "def" subdirectory structure the files correctly for ATS/ETS2 to read them.

Here is how genconfig.pl identifies engine, sound, and transmission configs:
- Anything starting with "interior_" or "exterior_" will go in the "sound" folder.
- Anything ending with "speed.sii" will go in the "transmission" folder.
- Anything else will go in the "engine" folder.

The folders included in this repo can serve as examples.
