# JokerDisplay - Balatro Mod

Simple Balatro mod that displays information such as modifiers or relevant hands, ranks or suits underneath the Joker.

## Installation

1. Install [Steamodded](https://github.com/Steamopollys/Steamodded)
2. Download the [latest release](https://github.com/nh6574/JokerDisplay/releases)
3. Drop JokerDisplay.lua into your Balatro mods folder (%appdata%\Balatro\Mods)

## Examples

![Example 1](examples/example_1.png)
![Example 2](examples/example_2.png)
![Example 3](examples/example_3.png)

_For information on all the Jokers, please refer to the [examples document](examples/README.md)_

## Future Improvements and Known Issues

- Blueprint and Brainstorm should display the information of the Joker they're copying. They also have a small graphical glitch when you get them for the first time.
- Loyalty Card updates the multiplier at the same time you play the last hand it's active in so it displays X1 instead of X4 like it should.
- Some jokers starts on +0 on a reload. (Clicking on something fixes it)
- Retriggering card Jokers don't factor into other Jokers' calculations.
- Blueprint and Brainstorm don't factor into Basecall Card's calculations.
- Some cards might not update properly when Vampire is used on a Stone Card.
- Matador doesn't calculate if the current hand triggers the Boss ability.
- If you sell Oops! All 6s other Jokers affected by it won't reload.
- Some Jokers display nothing when maybe they should (feel free to suggest).
- I've tried to use native Balatro terms for localization but some Jokers might display information in English.
- Text can get a bit tiny when there's too much information.
- UI might be crappy in some places (or all places).
- Held Planet cards could display their multiplier if the player has the Observatory voucher.

Feel free to [open an issue](https://github.com/nh6574/JokerDisplay/issues) for suggestions or bug reports.

## Contributing

I don't know how much time I'm going to dedicate to this (I'm not really _that_ into Balatro), so please feel free to fork or do PRs if you feel like you can improve on this or fix any of the problems above!

Also I would appreciate if people contect me when there are updates to the game or Steamodded that break any features or add content.

## Contact

If you have any issues feel free to contact me on Twitter: [@nh6574](https://twitter.com/nh6574)

Or on Discord: nh6574

And here's my [ko-fi link](https://ko-fi.com/nh6574) if you feel especially grateful.
