# AdminUnknownFixes

Bridge mod for **Pyanodon**, **Angel’s**, **Bob’s**, and experimental **Yuoki** compatibility on Factorio 2.0.

This fork continues the old Py + Angel + Bob compatibility work and adds defensive fixes needed for a modern “maximum complexity” stack. The current tested target is:

- Factorio 2.0
- Pyanodon suite
- Angel’s mods
- Bob’s mods
- Yuoki Industries / Yuoki addons

The current goal is not perfect balance yet. The goal is first to make the stack **load, start a new game, and expose progression issues through gameplay testing**. Because naturally the first boss in Factorio modding is not biters, it is prototype validation.

## Current status

The stack now reaches game start with Bob + Angel + Py + Yuoki enabled.

Known working milestone:

- Game starts with the current compatibility patches.
- Yuoki legacy Bob ore names are rewritten to current ore item names.
- Several Factorio 2.0 prototype validation issues are patched or bypassed safely.
- Further gameplay testing is still required.

Expected remaining work:

- unreachable recipes
- unreachable technologies
- missing intermediates
- science-pack progression problems
- recipes using wrong machines/categories
- balance nonsense caused by old bridge recipes meeting modern mod versions

## Major compatibility fixes in this fork

### PyPostProcessing / legacy bridge handling

Some PyPostProcessing versions still expect old bridge mods such as `PyCoalTBaA` / `pyppatba`.

This fork includes compatibility handling for that situation:

- suppresses the obsolete “Please install PyCoal Touched By an Angel” hard-stop when AdminUnknownFixes is acting as the active bridge
- keeps optional stub mods available for setups that still require them
- patches PyPP impossible-research validation where hidden prerequisite checks conflict with bridge replacements

### Angel’s recipe override normalization

Angel’s override functions can encounter old short-form recipe entries or malformed entries created by other compatibility layers.

This fork normalizes recipe ingredients/results and wraps Angel OV helpers so queued recipe patches are converted to safer Factorio 2.0-style entries before Angel executes them.

This prevents crashes around entries without `.name` and similar recipe-table shape problems.

### Bob’s optional/moved technology guards

Some old bridge code references Bob or Angel technologies that no longer exist, were renamed, or are optional depending on mod settings.

This fork adds guards/shims for missing optional technologies, including old Bob axe technologies and several Angel smelting/metallurgy technologies.

### Factorio 2.0 `next_upgrade` validation fixes

Factorio 2.0 validates `next_upgrade` more strictly.

This fork clears invalid `next_upgrade` links when:

- an entity mines into a hidden item product
- the upgrade target is missing
- the upgrade target has incompatible collision/selection boxes

This fixes startup failures for prototypes such as:

- `pumpjack`
- `chemical-plant`
- `oil-refinery`
- `lab -> bob-lab-2`

The upgrade planner loses some links, but the game loads. A tragic sacrifice, truly.

### Yuoki legacy Bob ore compatibility

Older Yuoki/Bob bridge recipes can reference obsolete Bob ore names such as:

- `bob-tungsten-ore`
- `bob-gold-ore`
- `bob-lead-ore`
- `bob-nickel-ore`

Modern Yuoki uses plain ore names such as:

- `tungsten-ore`
- `gold-ore`
- `lead-ore`
- `nickel-ore`

This fork rewrites old Yuoki bridge recipe references from legacy Bob names to current ore names where the replacement exists.

Current mapping includes:

| Legacy Bob/Yuoki name | Current replacement |
|---|---|
| `bob-bauxite-ore` | `bauxite-ore` |
| `bob-cobalt-ore` | `cobalt-ore` |
| `bob-gem-ore` | `gem-ore` |
| `bob-gold-ore` | `gold-ore` |
| `bob-lead-ore` | `lead-ore` |
| `bob-nickel-ore` | `nickel-ore` |
| `bob-quartz` | `quartz` |
| `bob-quartz-ore` | `quartz` |
| `bob-rutile-ore` | `rutile-ore` |
| `bob-silver-ore` | `silver-ore` |
| `bob-tin-ore` | `tin-ore` |
| `bob-tungsten-ore` | `tungsten-ore` |
| `bob-zinc-ore` | `zinc-ore` |

The patch rewrites:

- `result`
- `results[]`
- `main_product`
- ingredients

If no replacement exists, the affected Yuoki bridge recipe is disabled rather than allowing Factorio to fail during prototype validation.

## Building release zips

From the repository root:

- **Windows:** `pwsh -File scripts/package-mods.ps1`
- **Unix:** `./scripts/package-mods.sh`
- **WSL quick install:** `./scripts/package-install-wsl.sh`

The WSL helper builds the mod zip and installs it into the Windows Factorio mods folder.

Default Windows target:

```bash
/mnt/c/Users/$WINDOWS_USER/AppData/Roaming/Factorio/mods
```

Override if needed:

```bash
WINDOWS_USER=boris ./scripts/package-install-wsl.sh
```

or:

```bash
FACTORIO_MODS="/mnt/c/Users/boris/AppData/Roaming/Factorio/mods" ./scripts/package-install-wsl.sh
```

## Manual stub installs

Some setups still need empty sibling mods so PyPostProcessing’s dependency or Angel’s + Py gate is satisfied.

If your mod list or PyPP version still requires them, download and install both zips into your Factorio `mods` folder. They add no prototypes.

| Stub | Direct download |
|---|---|
| `pyppatba` | `stubs/pyppatba_0.0.1.zip` |
| `PyCoalTBaA` | `stubs/PyCoalTBaA_0.0.1.zip` |

Install location:

- Windows: `%APPDATA%\Factorio\mods`
- Linux/macOS: `~/.factorio/mods`

Factorio 2.0 loads mods from zip files named `Name_Version.zip` in that folder.

## Gameplay QA

Startup is currently working for the target stack, but gameplay progression still needs testing.

Recommended test checklist:

- start new freeplay
- check burner/start progression
- check first automation chain
- check first science pack path
- check early mining and smelting loops
- check Yuoki atomics recipes after ore-name rewrites
- watch for recipes using missing items/fluids
- watch for technologies with missing prerequisites
- watch for unreachable science packs
- watch for machines unable to craft required early recipes

When reporting issues, include:

```text
Recipe/technology/entity:
What was attempted:
Expected result:
Actual result:
Exact error text or screenshot:
Mod list if changed:
```

## Notes

This fork is currently a practical compatibility rescue for a very large mod stack. Some fixes deliberately prefer “load and keep progression inspectable” over perfect preservation of every old bridge mechanic.

Balance cleanup should happen after startup and early progression are stable.
