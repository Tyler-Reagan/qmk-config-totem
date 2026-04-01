QMK_DIR  := $(HOME)/vial-qmk
KB       := geigeigeist/totem
KM       ?= tyler
TARGET   := geigeigeist_totem_$(KM)
UF2      := $(TARGET).uf2
OUT_DIR  := firmware

# Available keymaps:
#   tyler  — ZMK-ported personal layout, Vial-compatible (default)
#   vial   — original geist layout, Vial-compatible
#   default — upstream default layout (no Vial)

.PHONY: help compile flash-left flash-right sync-to-fw sync-from-fw commit

help:
	@echo "TOTEM QMK workflow"
	@echo ""
	@echo "  make compile       Build firmware → $(OUT_DIR)/$(UF2)  [KM=$(KM)]"
	@echo "  make flash-left    Compile + flash left half (sets EE_HANDS handedness)"
	@echo "  make flash-right   Compile + flash right half (sets EE_HANDS handedness)"
	@echo "  make sync-to-fw    Copy keymap from this repo → vial-qmk (before compile)"
	@echo "  make sync-from-fw  Copy UF2 + updated keyboard files from vial-qmk → here"
	@echo "  make commit        Stage all changes and open git commit"
	@echo ""
	@echo "Override keymap:  make compile KM=vial"
	@echo ""
	@echo "Typical first-time flash workflow:"
	@echo "  1. make sync-to-fw"
	@echo "  2. Plug in LEFT half solo, put in bootloader (double-tap reset)"
	@echo "     make flash-left"
	@echo "  3. Plug in RIGHT half solo, put in bootloader (double-tap reset)"
	@echo "     make flash-right"
	@echo ""
	@echo "Subsequent updates (handedness already set in EEPROM):"
	@echo "  1. make sync-to-fw && make compile"
	@echo "  2. Drag-drop $(OUT_DIR)/$(UF2) onto each half mounted as USB drive"

# ── Build ─────────────────────────────────────────────────────────────────────

compile: sync-to-fw
	cd $(QMK_DIR) && qmk compile -kb $(KB) -km $(KM)
	@mkdir -p $(OUT_DIR)
	cp $(QMK_DIR)/$(UF2) $(OUT_DIR)/$(UF2)
	@echo "✓ $(OUT_DIR)/$(UF2) ready"

# ── Flash ─────────────────────────────────────────────────────────────────────
# flash-left / flash-right write EE_HANDS handedness to the XIAO's emulated
# EEPROM so each half knows its role.  Flash each half SOLO (other half
# disconnected).  After first-time setup you can simply drag-drop the UF2.

flash-left: sync-to-fw
	cd $(QMK_DIR) && qmk flash -kb $(KB) -km $(KM) -bl uf2-split-left

flash-right: sync-to-fw
	cd $(QMK_DIR) && qmk flash -kb $(KB) -km $(KM) -bl uf2-split-right

# ── Sync ──────────────────────────────────────────────────────────────────────

KEYMAP_SRC := $(QMK_DIR)/keyboards/$(KB)/keymaps/$(KM)
KEYMAP_DST := totem/keymaps/$(KM)
BOARD_SRC  := $(QMK_DIR)/keyboards/$(KB)
BOARD_DST  := totem

sync-to-fw:
	@echo "→ Syncing keymap $(KM) to vial-qmk..."
	@mkdir -p $(KEYMAP_SRC)
	cp $(BOARD_DST)/config.h    $(BOARD_SRC)/config.h
	cp $(KEYMAP_DST)/keymap.c   $(KEYMAP_SRC)/keymap.c
	cp $(KEYMAP_DST)/config.h   $(KEYMAP_SRC)/config.h
	cp $(KEYMAP_DST)/rules.mk   $(KEYMAP_SRC)/rules.mk
	cp $(KEYMAP_DST)/vial.json  $(KEYMAP_SRC)/vial.json
	@echo "✓ Synced"

sync-from-fw:
	@echo "← Syncing from vial-qmk..."
	@mkdir -p $(OUT_DIR)
	cp $(QMK_DIR)/$(UF2)                            $(OUT_DIR)/$(UF2)
	cp $(QMK_DIR)/keyboards/$(KB)/config.h          totem/config.h
	cp $(QMK_DIR)/keyboards/$(KB)/keyboard.json     totem/keyboard.json
	cp $(QMK_DIR)/keyboards/$(KB)/totem.c           totem/totem.c
	cp $(KEYMAP_SRC)/keymap.c                       $(KEYMAP_DST)/keymap.c
	cp $(KEYMAP_SRC)/config.h                       $(KEYMAP_DST)/config.h
	cp $(KEYMAP_SRC)/rules.mk                       $(KEYMAP_DST)/rules.mk
	cp $(KEYMAP_SRC)/vial.json                      $(KEYMAP_DST)/vial.json
	@echo "✓ Synced"

# ── Git ───────────────────────────────────────────────────────────────────────

commit:
	git -C $(QMK_DIR) add keyboards/$(KB)/keymaps/$(KM)/
	@echo "Changes staged in vial-qmk (commit there separately if needed)"
	git add -A
	git status
	git commit
