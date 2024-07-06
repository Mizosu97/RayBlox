# RayBlox
Fully raytraced lighting engine for Roblox, works natively in-game.

## Usage
Get the RBXM and place it into into the startergui, then press `=` to render a frame while the game is running.
The version of RayBlox in the main branch is the most recent developer version, which may be extremely broken.
A stable version will be published to the releases page when one exists.

Some settings can be found as variables at the top of the script:
- `SCALE` - Controls how many times the resolution is downscaled. A scale of 8 will make the render resolution 8 times less than the user's native resolution.
- `BOUNCES` - How many times a single ray can reflect off of a surface,
- `RAYSPERPIXEL` - How many rays are fired per pixel. The colors of all rays belonging to a pixel are averaged to determine the color of the pixel.

### Usage Tips
- Don't move the camera while the frame is rendering, it will garble the image.
- Don't resize the Roblox window after the game has been loaded, it will garble the image.

## Contributing
Just make a pull request to the main branch.

## Game
A game exists that always features the latest developer edition of RayBlox. It can be found [here](https://www.roblox.com/games/18351320382/Roblox-Shaders).

