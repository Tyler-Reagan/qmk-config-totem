<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/docs/images/TOTEM_logo_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="/docs/images/TOTEM_logo_bright.svg">
  <img alt="TOTEM logo" src="/docs/images/TOTEM_logo_bright.svg">
</picture>

# QMK Config — TOTEM Split Keyboard

A 38-key column-staggered split keyboard running [Vial](https://get.vial.today/) (a fork of [QMK](https://docs.qmk.fm/)) on two [Seeed XIAO RP2040](https://wiki.seeedstudio.com/XIAO-RP2040/) microcontrollers.

- **Hardware files & build guide:** [GEIGEIGEIST/TOTEM](https://github.com/GEIGEIGEIST/TOTEM)
- **ZMK config (wireless):** see `zmk-config-studio/` — same layout, wireless variant
- **Firmware source:** [vial-qmk](https://github.com/vial-kb/vial-qmk) fork at `~/vial-qmk`

### Keymaps

| Keymap | Description |
|---|---|
| `tyler` | Personal layout — QMK/Vial port of the ZMK keymap. **Default.** |
| `vial` | Original geist layout (Colemak + QWERTY + Lower/Raise/Adjust), Vial-compatible |
| `default` | Upstream default layout, no Vial support |

Build a specific keymap with `make compile KM=vial`. All Makefile targets respect `KM`.

![TOTEM layout](/docs/images/TOTEM_layout.svg)

---

<details>
<summary><strong>Prerequisites</strong></summary>

### 1. Vial-QMK firmware repo

This repo's `Makefile` expects the vial-qmk firmware repo cloned at `~/vial-qmk`:

```sh
git clone https://github.com/vial-kb/vial-qmk.git ~/vial-qmk
cd ~/vial-qmk
git submodule update --init --recursive
```

If any submodule directory ends up empty after the above, force a checkout:

```sh
git -C ~/vial-qmk/lib/pico-sdk checkout HEAD -- .
git -C ~/vial-qmk/lib/lufa    checkout HEAD -- .
git -C ~/vial-qmk/lib/printf  checkout HEAD -- .
git -C ~/vial-qmk/lib/vusb    checkout HEAD -- .
```

### 2. QMK CLI

```sh
# macOS (via uv — recommended)
brew install uv
uv tool install qmk

# or via pip
pip3 install qmk
```

Run `qmk setup` once to install the ARM toolchain and verify the environment:

```sh
qmk setup
```

> **Note:** On macOS the ARM toolchain installs to `~/Library/Application Support/qmk/bin/`.
> Use `qmk compile` / `qmk flash` (not bare `make`) so the CLI adds that path automatically.

### 3. `make`

```sh
xcode-select --install   # macOS — provides make, git, etc.
```

</details>

---

<details>
<summary><strong>Bootloader mode (Seeed XIAO RP2040)</strong></summary>

The XIAO must be in bootloader mode before it will accept a firmware flash. It appears as a USB mass storage device named **`RPI-RP2`**.

**Method 1 — Double-tap reset (recommended, works any time)**
1. Tap the `RESET` button on the XIAO twice in quick succession (~500 ms).
2. The `RPI-RP2` drive mounts on your computer.

**Method 2 — Boot button on power-up**
1. Hold the `BOOT` button on the XIAO.
2. While holding, plug in the USB cable (or press `RESET`).
3. Release `BOOT`. The `RPI-RP2` drive mounts.

**Method 3 — QMK `QK_BOOT` key**
If the keyboard is already running QMK firmware, tap the `QK_BOOT` key in your keymap (BOOT layer outer-pinky keys in the `tyler` keymap; ADJUST layer in `vial`/`default`). The half you triggered it on will enter bootloader mode.

> Flash **one half at a time**. Disconnect the TRRS/serial cable between halves while flashing.

</details>

---

<details>
<summary><strong>Makefile workflow</strong></summary>

Run `make` or `make help` from the repo root to see all targets.

### First-time flash (sets handedness in EEPROM)

Both halves run identical firmware. The `EE_HANDS` setting stores which side each XIAO is on in its emulated EEPROM. You only need to do this once per controller.

```sh
# Step 1 — plug in LEFT half solo (no TRRS), put it in bootloader mode
make flash-left

# Step 2 — plug in RIGHT half solo (no TRRS), put it in bootloader mode
make flash-right
```

Each command syncs your keymap to `~/vial-qmk`, compiles, and waits for the XIAO to appear as `RPI-RP2`, then flashes automatically.

### Subsequent firmware updates

Handedness is already stored in EEPROM, so you can flash either half with the plain UF2:

```sh
make compile          # builds firmware/geigeigeist_totem_tyler.uf2
```

Then either:
- Let `qmk flash` detect the device, **or**
- Drag-drop the UF2 from the `firmware/` directory onto the `RPI-RP2` drive manually (both halves, one at a time).

### Editing keymaps

Edit files under `totem/keymaps/tyler/` (or `totem/keymaps/vial/` for the geist layout), then:

```sh
make compile          # auto-syncs to ~/vial-qmk, compiles, copies UF2 back
```

### All targets

| Target | Description |
|---|---|
| `make compile` | Sync keymap → vial-qmk, compile, copy UF2 to `firmware/` |
| `make flash-left` | Compile + flash left half (writes EE_HANDS to EEPROM) |
| `make flash-right` | Compile + flash right half (writes EE_HANDS to EEPROM) |
| `make sync-to-fw` | Copy keymap files from this repo → vial-qmk |
| `make sync-from-fw` | Copy UF2 + keyboard definition files from vial-qmk → here |
| `make commit` | Stage changes in both repos and open git commit |

</details>

---

<details>
<summary><strong>GUI tools</strong></summary>

### Vial (recommended)

[Vial](https://get.vial.today/) is a real-time keymap editor — no reflashing needed for keymap changes. This firmware is compiled with Vial support.

- Download the desktop app: [get.vial.today](https://get.vial.today/)
- Plug in either half (connected to the other via TRRS), open Vial, and your TOTEM layout appears automatically.
- Changes are saved instantly to the keyboard's EEPROM — no compile step.
- Supports layers, tap-dance, combos, key overrides, and macros via the GUI.

> Vial requires the keyboard to be running Vial-enabled firmware (which this repo produces). It will not connect to stock QMK firmware.

### VIA

[VIA](https://www.caniusevia.com/) is an older GUI configurator. The firmware includes `VIA_ENABLE`, so VIA will work, but Vial is a strict superset of VIA and is preferred.

- Web app: [usevia.app](https://usevia.app/) (Chrome/Edge required)
- Desktop app: [github.com/the-via/releases](https://github.com/the-via/releases)

### QMK Toolbox

[QMK Toolbox](https://github.com/qmk/qmk_toolbox/releases) is a GUI for flashing firmware — useful if you prefer not to use the command line.

1. Open QMK Toolbox.
2. Click **Open** and select the UF2 from the `firmware/` directory (e.g. `firmware/geigeigeist_totem_tyler.uf2`).
3. Put your XIAO into bootloader mode (see above). QMK Toolbox detects it automatically.
4. Click **Flash**.
5. Repeat for the other half.

> QMK Toolbox does **not** set EE_HANDS handedness. For first-time setup, use `make flash-left` / `make flash-right` from the command line, or drag-drop the UF2 after setting handedness another way.

### QMK Configurator

[QMK Configurator](https://config.qmk.fm/) is a browser-based keymap builder for stock QMK. It does **not** support Vial firmware. If you want a browser-based GUI, use [usevia.app](https://usevia.app/) or the Vial desktop app instead.

</details>

---

<details>
<summary><strong>FAQ</strong></summary>

**Q: Why is there only one UF2 for a split keyboard?**
Both halves run identical firmware. The RP2040 scans its own 4×5 key matrix (19 keys) and sends the result to the master half via the serial link on GP0/GP1. `EE_HANDS` tells each half whether its keys occupy the left or right half of the full 8×5 matrix. The single UF2 handles both — handedness is the only difference, and it lives in EEPROM.

**Q: Do I have to redo the EE_HANDS flash every time I update my keymap?**
No. Once each XIAO has its handedness written, subsequent updates only need the plain UF2 (`make compile` + drag-drop or `qmk flash`).

**Q: One half isn't responding / both halves type the same side's keys.**
The halves likely have the same handedness stored. Re-run `make flash-left` and `make flash-right` with each half solo and the TRRS disconnected.

**Q: The keyboard isn't recognised by Vial.**
Make sure the firmware was compiled from this repo (Vial-enabled). Stock QMK firmware will not connect. If you flashed a different UF2, recompile with `make compile` and reflash.

**Q: `qmk compile` fails with `ast.Num` errors.**
Your QMK CLI is running on Python 3.12+, which removed `ast.Num`. Apply this fix in `~/vial-qmk/lib/python/qmk/math.py` — replace the `_eval` function's first branch:

```python
# Before
if isinstance(node, ast.Num):
    return node.n

# After
if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
    return node.value
elif isinstance(node, ast.Num):
    return node.n
```

**Q: `arm-none-eabi-gcc: command not found` when running bare `make`.**
The ARM toolchain installs to `~/Library/Application Support/qmk/bin/`, which isn't in your shell `PATH`. Use `qmk compile` (via the `Makefile`) instead of invoking `make` directly in the `~/vial-qmk` directory.

**Q: `hardware/clocks.h: No such file or directory` during compile.**
The `lib/pico-sdk` submodule directory is empty. Fix:
```sh
git -C ~/vial-qmk/lib/pico-sdk checkout HEAD -- .
```

**Q: Can I use ZMK instead of QMK for wireless?**
Yes — see [GEIGEIGEIST/zmk-config-totem](https://github.com/GEIGEIGEIST/TOTEM). ZMK targets the XIAO BLE variant, not the RP2040.

</details>
