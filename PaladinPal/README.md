# Paladin Pal

A World of Warcraft: Forever addon that helps with Seal usage.

## What it does (so far)

- Shows an icon for your active Seal, with a duration sweep and its name.
- Shows a red "NO SEAL" warning if you're in combat with no Seal up.
- Only loads its UI for Paladins.

## Install

Copy the `PaladinPal` folder into your game's `Interface/AddOns/` folder so the
path ends in `AddOns/PaladinPal/PaladinPal.toc`. During the beta, community
guides put this under `_classic_beta_`; it may move at launch.

## Commands

| Command       | Effect                                 |
| ------------- | -------------------------------------- |
| `/ppal lock`   | Lock the frame in place                |
| `/ppal unlock` | Unlock the frame so you can drag it    |
| `/ppal reset`  | Move the frame back to its default spot |
| `/ppal warn`   | Toggle the in-combat no-seal warning   |

## Files

| File         | Purpose                                         |
| ------------ | ----------------------------------------------- |
| `PaladinPal.toc` | Manifest: metadata, saved variables, load order |
| `Core.lua`   | Startup, saved settings, slash commands         |
| `Seals.lua`  | Finds your active Seal and listens for changes  |
| `UI.lua`     | The on-screen icon                              |

## To check in-game

- `## Interface: 16001` in the `.toc` comes from community guides. Confirm with
  `/dump select(4, GetBuildInfo())` and update it if it differs.
- Seals are detected by name (`Seal of ...`), so only English clients work for now.
