# RayBlox
Fully raytraced lighting engine for Roblox, works natively in-game.

## Usage
Throw the RBXM in startergui, then press `=` to render a frame while the game is running.

Some settings can be found as variables at the top of the script:
- `SCALE` - Controls how many times the resolution is downscaled. A scale of 8 will make the render resolution 8 times less than the user's native resolution.
- `BOUNCES` - How many times a single ray can reflect off of a surface,
- `RAYSPERPIXEL` - How many rays are fired per pixel. The colors of all rays belonging to a pixel are averaged to determine the color of the pixel.

