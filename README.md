Create template .sii files using "%truck%" anywhere you would normally put the truck name. Put them in this directory.

List the trucks you want to support in "trucks.txt", one per line. You need to use the folder name for the truck, eg "peterbilt.389"

- Anything starting with "interior_" or "exterior_" will go in the "sound" folder.
- Anything ending with "speed.sii" will go in the "transmission" folder.
- Anything else will go in the "engine" folder.

When you're ready, simply run genconfig.pl and and it will process any .sii files in the current working directory.
