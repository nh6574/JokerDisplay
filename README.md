# JokerDisplay - Balatro Mod

Simple Balatro mod that displays information such as modifiers or relevant hands, ranks or suits underneath Jokers.

## Installation

1. Install [Steamodded](https://github.com/Steamopollys/Steamodded)
2. Download the [latest release](https://github.com/nh6574/JokerDisplay/releases)
3. Extract JokerDisplay.zip into your Balatro mods folder (%appdata%\Balatro\Mods)

Tested with Steamodded 0.9.8 and 1.0.0.

## Usage

* Right-click the display or a Joker to hide/unhide all displays (or use the back button on your controller over a Joker).
* Left-click the display to hide/unhide the second row of text. (Mouse only)

## Examples

![Example 1](examples/example_1.png)
![Example 2](examples/example_2.png)
![Example 3](examples/example_3.png)

_For information on all the Jokers, please refer to the [examples document](examples/README.md)_ (it's a bit outdated but gives you a general idea)

Feel free to [open an issue](https://github.com/nh6574/JokerDisplay/issues) for suggestions or bug reports.

## Mod Support

This mod only supports vanilla jokers but you can add support for it in your mod by defining how the display should look.
Make sure that JokerDisplay.Definitions is loaded and add a new value with your joker key (ex. JokerDisplay.Definitions\["j_my_custom"\])

Example:
```lua
--- It's recommended to keep any reminder text in line_2 and only use line_1 for modifiers with only numbers

-- Adds +10 mult for every 6 played
JokerDisplay.Definitions["j_my_custom"] = {
  line_1 = {
    { text = "+",                             colour = G.C.MULT },
    { ref_table = "card.joker_display_values", ref_value = "mult",  colour = G.C.MULT }
  },
  line_2 = {
    { text = "(6)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
  },
  calc_function = function(card)
    local mult = 0
    local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
    local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
    for k, v in pairs(scoring_hand) do
      if not v.debuff and v:get_id() and v:get_id() == 6 then
        local retriggers = JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown')
                          and scoring_hand or nil)
        mult = mult + 10 * retriggers
      end
    end
    card.joker_display_values.mult = mult
  end
}
```

Check joker_definitions.lua for a hint on how to implement your own jokers (or modify vanilla ones). Complex custom Jokers might need to inject code into JokerDisplay's functions.
I recommend keeping your definitions in a separate file as they can get quite long and bloat your code.

## Contributing

I don't know how much time I'm going to dedicate to this (I'm not really _that_ into Balatro), so please feel free to fork or do PRs if you feel like you can improve on this or fix any of the problems above!

Also I would appreciate if people contact me when there are updates to the game or Steamodded that break any features or add content.

## Contact

If you have any issues feel free to contact me on Twitter: [@nh6574](https://twitter.com/nh6574)

Or on Discord: nh6574

And here's my [ko-fi link](https://ko-fi.com/nh6574) if you feel especially grateful.
