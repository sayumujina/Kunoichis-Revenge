# About Kunoichi's Revenge

Kunoichi's Revenge is a turn-based game developed in Roblox as part of the final year project of the University of Greenwich.

## Development

1. Download [Rokit](https://github.com/rojo-rbx/rokit/releases/latest) and install it.
2. Run `scripts/install.sh` to install all necessary packages and tools.
3. Run `rojo plugin install` to install the Rojo sync plugin to your Studio.
4. Look for **MENU_PLACE_ID** and **GAME_PLACE_ID** in the `init.server.luau` files in both the game and menu folders, and replace them with your own place IDs.
   - My place IDs are private, so you cannot access the game using them; so use your own.
5. Run `rojo serve` or use `CTRL + SHIFT + P` to open the Rojo menu, then hit the run button to start serving the project. This syncs the project from your IDE to Roblox Studio.
   - Read [Rojo's documentation](https://rojo.space/docs/v7/properties/) to view the list of supported file types.

## Build

To build the place from scratch, use:

```bash
rojo build -o "game.rbxl"
```
