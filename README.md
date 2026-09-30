# Touhou 6: Embodiment of Scarlet Devil — Nintendo Switch Port
*(東方紅魔郷　〜 the Embodiment of Scarlet Devil)*

![Platform](https://img.shields.io/badge/Platform-Nintendo%20Switch-e60012?style=for-the-badge&logo=nintendoswitch&logoColor=white)
![Status](https://img.shields.io/badge/Status-Fully%20Playable-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge)

A native homebrew port of ZUN's legendary 2002 bullet hell danmaku masterpiece **Touhou 6: Embodiment of Scarlet Devil** for the **Nintendo Switch** (Horizon OS).

Built upon the cross-platform decompilation engine [GensokyoClub/th06](https://github.com/GensokyoClub/th06), this port features custom hardware-accelerated OpenGL ES 3.2 rendering over Nouveau/Mesa, seamless Nintendo Switch Joy-Con and Pro Controller support, native 1280x720 window resolution scaling with pure OLED black letterbox borders, and an intelligent filename alias resolver designed for FAT32 SD cards.

---

## 🆕 What's New (September 2026 update)

* 🌏 **Proper name in hbmenu:** shows `東方紅魔郷　～ the Embodiment of Scarlet Devil` on consoles set to 日本語 and `Touhou 6: the Embodiment of Scarlet Devil` everywhere else, with **ZUN / Team Shanghai Alice** as the author — like the other Touhou ports.
* 📁 **One folder for all Touhou ports:** the game can now live in `sd:/switch/touhou/touhou6/` (recommended), next to the other ports. The NRO's own folder is always checked first, so your current setup keeps working.
* Nothing in the game itself changed.

---

## ✨ Key Features

* 🚀 **Full 60 FPS Performance:** Smooth, rock-solid 60 FPS danmaku gameplay across all Nintendo Switch models (V1 Erista, V2 Mariko, Switch Lite, Switch OLED) running natively on Horizon OS—no Linux, Box64, or Wine required.
* 🦇 **Embedded Official Artwork:** Features the classic 2002 CD release cover silhouette embedded directly within the `.nro` asset header for seamless display in Homebrew Menu, Sphaira, and custom home screen forwarders.
* 🖥 **OLED-Optimized Widescreen Scaling:** Automatically scales the original 640x480 gameplay viewport centered inside the Switch's native 1280x720 display. Double-buffered hardware scissor testing (`GL_SCISSOR_TEST`) guarantees that the 16:9 side pillarboxes remain 100% pure black (`#000000`), preserving contrast and extending battery life on OLED screens.
* 🎮 **Native Controller Support:** Seamless out-of-the-box mapping for Joy-Con (Handheld, Grip, or detached) and Nintendo Switch Pro Controllers via SDL2 GameController API, complete with slow-motion focus mode (`L`/`R`/`ZL`/`ZR`) and menu navigation.
* 🧠 **Defensive Smart Filename Resolver:** FAT32/ExFAT filesystems on Switch often reject Japanese Shift-JIS / UTF-8 characters (`東方紅魔郷.cfg`), and Windows extraction tools frequently strip non-ASCII prefixes from filenames (`紅魔郷CM.DAT` → `CM.DAT`). The engine includes a low-level filesystem interceptor that automatically locates and resolves stripped ASCII filenames (`CM.DAT`, `MD.DAT`, `.cfg`, `th06.cfg`) transparently.
* 🎵 **Lossless Audio & BGM Support:** Full support for sound effects (`CM.DAT`) and lossless WAV background music playback (`bgm/` folder).

---

## 📥 Installation Guide

> ⚠️ **Disclaimer:** In compliance with ZUN's guidelines and copyright law, this repository contains **ONLY the homebrew engine code**. Game asset archives (`*.DAT`) are not distributed. You must legally own a copy of *Touhou 6: Embodiment of Scarlet Devil v1.02h*.

### 1. SD Card File Structure
1. Ensure your Nintendo Switch is running custom firmware (Atmosphère CFW).
2. Download the latest `touhou6.nro` from the [Releases](../../releases) tab (or build from source).
3. Create the folder `sd:/switch/touhou/touhou6/` on your SD card and copy `touhou6.nro` into it.
4. Copy the data archives from your legitimate Touhou 6 PC folder directly into the same directory:
   ```text
   sd:/switch/touhou/touhou6/
       ├── touhou6.nro       # Nintendo Switch homebrew executable
       ├── CM.DAT            # Game data (or 紅魔郷CM.DAT)
       ├── ED.DAT            # Endings data (or 紅魔郷ED.DAT)
       ├── IN.DAT            # Stage intro data (or 紅魔郷IN.DAT)
       ├── MD.DAT            # MIDI/Music data (or 紅魔郷MD.DAT)
       ├── ST.DAT            # Stage data (or 紅魔郷ST.DAT)
       ├── TL.DAT            # Title screen data (or 紅魔郷TL.DAT)
       └── msgothic.ttc      # Japanese font 
   ```
   *(Note: Whether your files are named with full Japanese characters `紅魔郷CM.DAT` or stripped ASCII `CM.DAT`, the engine will locate and load them automatically).*

   **Recommended place: `sd:/switch/touhou/touhou6/`.** Keeping every Touhou port in one `sd:/switch/touhou/` folder (`touhou6`, `touhou7`, `touhou8` …) is much tidier than a separate folder per game. Other places still work: the port first looks in its own folder (wherever the NRO is), then for a `th06` / `touhou6` folder (any capitalisation) directly on the SD card, in `switch/`, `touhou/`, `switch/touhou/`, `games/` or `roms/` — so older layouts keep working.

### 2. Enabling Background Music (BGM)
Because Horizon OS lacks a system MIDI synthesizer, Touhou 6 plays background music on the Switch via ZUN's official WAV music mode:
1. Locate or download the standard *Touhou 6 EoSD WAV BGM / Lossless Soundtrack Pack*.
2. Create a folder named `bgm` inside your game directory (`sd:/switch/touhou/touhou6/bgm/`).
3. Place all soundtrack WAV files (`th06_01.wav` through `th06_17.wav`) along with their loop point definition files (`*.pos`) inside `bgm/`.
4. Launch the game. The engine will automatically detect `bgm/th06_01.wav`, configure `musicMode` to WAV, and play full soundtrack audio. *(If needed, navigate to Options -> BGM inside the game menu and set it to **WAV**).*

### 3. Launching
Run `touhou6.nro` from the **Homebrew Menu (hbmenu)**, **Sphaira launcher**, or install a home screen forwarder shortcut.

---

## 🕹 Controls

| Nintendo Switch Button | Action |
| :--- | :--- |
| **Left Stick / D-Pad** | Character Movement |
| **A** *(or B)* | Shoot / Confirm |
| **B** *(or A)* | Bomb / Cancel |
| **L / R / ZL / ZR** | Focus (Precision Slow-Motion Movement) |
| **+ (Plus)** | Pause / In-Game Menu |

---

## 🛠 Building from Source

### Automated Build (GitHub Actions)
This repository includes a pre-configured GitHub Actions CI pipeline (`.github/workflows/build-switch.yml`). Simply fork or push this repository to GitHub, and the CI workflow will automatically compile `touhou6.nro` inside an official `devkitA64` container and upload the ready-to-play executable as a downloadable workflow artifact.

### Local Build (Linux / macOS / WSL)
1. Install [devkitPro](https://devkitpro.org/wiki/Getting_Started) with `devkitA64` and `libnx`.
2. Install required Switch portlibs:
   ```bash
   sudo dkp-pacman -Syu
   sudo dkp-pacman -S switch-sdl2 switch-sdl2_image switch-sdl2_ttf switch-mesa switch-libdrm_nouveau switch-libpng switch-libjpeg-turbo switch-freetype switch-zlib
   ```
3. Set environment variables and compile:
   ```bash
   export DEVKITPRO=/opt/devkitpro
   export PATH=$DEVKITPRO/tools/bin:$PATH

   # Pre-generate shader header embeds
   python3 scripts/gen_embeds.py

   # Build executable
   make -j$(nproc)
   ```

---

## 🤝 Credits & Acknowledgments

* **ZUN / Team Shanghai Alice** — Original creator and developer of the Touhou Project series.
* **[GensokyoClub](https://github.com/GensokyoClub/th06)** — For their monumental work on the byte-accurate C++ portable decompilation of Touhou 6.
* **Switchbrew & devkitPro Team** — For the open-source `libnx` SDK and Nintendo Switch toolchain.
