```
                                                       ▀▀▀▀▀     ▀▀▀▀▀          ▀▀█▀▀
                                                       ▄▀▀▀▄  ▄  ▄▀▀▀▄  ▄  ▄▀▀▀▄  █  ▄▀▀▀▄
                                                       █   █  █  █   █  █  █   █  █  █   █
                                                        ▀▀▀   █   ▀▀▀   █   ▀▀▀   ▀   ▀▀▀
                                                              █      ▄▄▄█▄▄▄    █   █
                                                              ▀      █  █  █     █▄█
                                                            ▀▀▀▀▀    █  █  █      ▀
                                                                     ▀  ▀  ▀
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

```

# TOTEM split keyboard

TOTEM is a 38-key column-staggered split keyboard by [@geigeigeist](https://github.com/GEIGEIGEIST). It uses two [Seeed XIAO RP2040](https://wiki.seeedstudio.com/XIAO-RP2040/) microcontrollers connected via TRRS.

See the [repo readme](../readme.md) for the full build, flash, and workflow documentation.

---

## Keyboard definition files

| File | Purpose |
|---|---|
| `keyboard.json` | QMK keyboard metadata (MCU, matrix pins, split config) |
| `config.h` | Board-level compile-time settings (handedness, EEPROM config) |
| `rules.mk` | Board-level build flags |
| `totem.h` | `LAYOUT()` macro — maps logical key positions to the 8×5 matrix |
| `totem.c` | Split keyboard callbacks (post-init, sync) |
| `halconf.h` | ChibiOS HAL config |
| `mcuconf.h` | RP2040 MCU peripheral config |

---

## Keymaps

| Keymap | Description |
|---|---|
| `tyler` | Personal layout — Vial-compatible port of the ZMK keymap. **Default.** |
| `vial` | Original geist layout (Colemak + QWERTY + Lower/Raise/Adjust), Vial-compatible |
| `default` | Upstream default layout, no Vial support |

Compile a keymap directly (bypassing the repo Makefile):

```sh
qmk compile -kb geigeigeist/totem -km tyler
qmk compile -kb geigeigeist/totem -km vial
qmk compile -kb geigeigeist/totem -km default
```

Or use `make compile` from the repo root (handles sync and output automatically).
